# CodeQL Playground

This repo is created to test some queries in https://github.com/openenclave/openenclave-security

## How to run queries

Generally, to run CodeQL queries, you need to
1) Build CodeQL database from source file
2) Run queries

Detailed steps
1. Download VS Code + [CodeQL extension](https://marketplace.visualstudio.com/items?itemName=GitHub.vscode-codeql)
2. Download [CodeQL CLI](https://docs.github.com/en/code-security/codeql-cli/getting-started-with-the-codeql-cli/setting-up-the-codeql-cli)
3. git clone this repo
4. `cd project/`
    1. Create database: `codeql database create demo-db --language=c-cpp --overwrite`
5. Open repo root folder in VS Code
6. Go to VS Code CodeQL Tab
    1. In the Database dropdown, select "From a folder"
    2. Select the `project/demo-db` folder
7. Open the `.ql` file you wish to run, for example `query_outside.ql`
8. Right click in the blank space of editor of opened file
9. Select "CodeQL: Run Query on Selected Database"
10. Wait and see query result in new panel
