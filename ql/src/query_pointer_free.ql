import cpp
import semmle.code.cpp.dataflow.new.DataFlow
import semmle.code.cpp.dataflow.new.TaintTracking
import semmle.code.cpp.controlflow.IRGuards

/**
 * Pointer Expresssion
 */
class PointerExpr extends Expr {
  PointerExpr() {
    getType().getUnderlyingType().getUnspecifiedType() instanceof PointerType or
    this.isConstant()
  }
}

/**
 * Denotes a Call to `free` function
 */
class FreeCall extends FunctionCall {
  FreeCall() {
    this.getTarget().getName().matches("free") or this.getTarget().getName().matches("oe_free")
  }

  VariableAccess getFreedVariableAccess() { result = getArgument(0) }
}

/**
 * Holds if the data flow node `n` is an expression or parameter of pointer type.
 */
predicate hasPointerType(DataFlow::Node n) {
  n.asExpr().getFullyConverted() instanceof PointerExpr or
  n.asParameter().getType().getUnderlyingType().getUnspecifiedType() instanceof PointerType
}

/**
 * Data flow configuration tracking pointer flow from expressions or parameters of pointer type
 * to their accesses.
 */
module PointerConfig implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node n) {
    hasPointerType(n) and
    // restrict to non-null values, as these are safe to repeatedly free
    not n.asExpr() instanceof NullValue
  }

  predicate isSink(DataFlow::Node n) {
    hasPointerType(n) and
    n.asExpr() instanceof VariableAccess
  }
}

module PointerFlow = TaintTracking::Global<PointerConfig>;

/**
 * A call that frees an argument, either directly or
 * by interprocedurally passing it to a free call within the callee.
 */
class EffectiveFreeCall extends FunctionCall {
  Expr freedArg;

  EffectiveFreeCall() {
    freedArg = this.getAnArgument() and
    exists(FreeCall freeCall, VariableAccess freedAccess |
      freeCall.getFreedVariableAccess() = freedAccess and
      // the argument of this call flows to the freed variable access
      PointerFlow::flow(DataFlow::exprNode(freedArg), DataFlow::exprNode(freedAccess)) and
      // but the result of this call does not; this avoids spuriously flagging pass-through functions
      not PointerFlow::flow(DataFlow::exprNode(this), DataFlow::exprNode(freedAccess))
    )
  }

  Expr getAFreedArgument() { result = freedArg }
}

from EffectiveFreeCall call
select call, call.getAFreedArgument(), call.getLocation()
