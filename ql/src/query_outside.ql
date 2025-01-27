import cpp
import semmle.code.cpp.dataflow.new.DataFlow
import semmle.code.cpp.dataflow.new.TaintTracking
import semmle.code.cpp.controlflow.IRGuards

/**
 * Function definition model for oe_is_outside_enclave
 */
class IsOutsideEnclaveFunction extends Function {
  IsOutsideEnclaveFunction() { this.getName() = "oe_is_outside_enclave" }

  Parameter getPointer() { result = getParameter(0) }

  Parameter getSize() { result = getParameter(1) }
}

/**
 * Call to oe_is_outside_enclave function
 */
class IsOutsideEnclaveFunctionCall extends FunctionCall {
  IsOutsideEnclaveFunctionCall() { this.getTarget() instanceof IsOutsideEnclaveFunction }
}

/**
 * isOutsideEnclaveBarrierGuardChecks - A gaurd condition to check if a basic block is
 * validated for envalve memory range protection by issuing a call to IsOutsideEnclave.
 */
predicate isOutsideEnclaveBarrierGuardChecks(IRGuardCondition g, Expr checked, boolean isTrue) {
  exists(Call call |
    g.getUnconvertedResultExpression() = call and
    call instanceof IsOutsideEnclaveFunctionCall and
    checked = call.getArgument(0) and
    isTrue = true
  )
}

/**
 * IsOutsideEnclaveBarrierConfig - Data-flow configuration to check if the sink is
 * protected by IsOutsideEnclave validation.
 */
module IsOutsideEnclaveBarrierConfig implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node source) {
    not exists(IsOutsideEnclaveFunctionCall fc | fc.getArgument(0) = source.asExpr())
  }

  predicate isSink(DataFlow::Node sink) {
    exists(AssignExpr assExp |
      assExp.getLValue().getType() instanceof PointerType and
      assExp.getRValue() = sink.asExpr()
    )
  }

  predicate isBarrier(DataFlow::Node node) {
    // /3 means there 3 parameters
    node = DataFlow::BarrierGuard<isOutsideEnclaveBarrierGuardChecks/3>::getABarrierNode()
  }
}

module IsOutsideEnclaveBarrierFlow = TaintTracking::Global<IsOutsideEnclaveBarrierConfig>;

from Expr r
where IsOutsideEnclaveBarrierFlow::flow(DataFlow::exprNode(r), DataFlow::exprNode(r))
select r, r.getLocation()
