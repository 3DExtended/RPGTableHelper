cd ..
rm -rf ./cobertura/
rm -rf ./coveragereport/

dotnet test --collect:"XPlat Code Coverage" --results-directory cobertura
reportgenerator -reports:"**/coverage.cobertura.xml" -targetdir:"coveragereport" -reporttypes:Html

code ./coveragereport/index.html