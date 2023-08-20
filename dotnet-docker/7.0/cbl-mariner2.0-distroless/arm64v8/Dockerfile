FROM mcr.microsoft.com/dotnet/runtime-deps:7.0-bookworm-slim

# The list of vulnerable packages is created externally
COPY vulnerable-packages.txt /vulnerable-packages.txt
COPY fix-vulnerabilities.sh /fix-vulnerabilities.sh
COPY remove-rdepends-of-vuln-pckgs.sh /remove-rdepends-of-vuln-pckgs.sh

# Remove packages
RUN chmod +x fix-vulnerabilities.sh && ./fix-vulnerabilities.sh
