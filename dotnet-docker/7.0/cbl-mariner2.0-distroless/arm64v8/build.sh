#/bin/bash

update_vulnerabilities() {
    docker run --rm -v $PWD:/tmp aquasec/trivy:latest image --format json --severity CRITICAL,HIGH,MEDIUM --no-progress --scanners vuln mcr.microsoft.com/dotnet/runtime-deps:7.0-bookworm-slim | jq -r '.Results[].Vulnerabilities[].PkgName' | sort | uniq > vulnerable-packages.txt
}

FILE="vulnerable-packages.txt"

if test -f "$FILE"; then
    if find "$FILE" -mtime -1 -print 2>/dev/null; then
        echo "The file $FILE exists on your filesystem and is newer than 1 day. No vulnerability check is executed."
    else
        echo "The file $FILE exists on your filesystem but is older than 1 day. Vulnerability check will be executed."
        update_vulnerabilities
    fi
else
    echo "The file $FILE does not exist on your filesystem. Vulnerability check will be executed."
    update_vulnerabilities
fi

# The dockerfile used in this command reads the file vulnerable-packages.txt and uninstalls them
# The script fix-vulnerabilites updates the packages and calls the script remove-depends-of-vuln-pckgs.sh
# The latter script then uninstalls the reverse dependencies of the vulnerabilities and the vulnerable package itself.
docker build . -t dotnethardened:7-0-bookworm-slim
