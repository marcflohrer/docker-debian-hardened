#!/bin/bash

# Default essential packages
default_essential_packages=("glibc" "krb5" "libgcc" "libstdc++" "openssl-libs" "zlib" "awk")

# Use either the provided essential packages or the default essential packages
if [ -n "$1" ]; then
    essential_packages=("${provided_essential_packages[@]}")
else
    essential_packages=("${default_essential_packages[@]}")
fi

# Check if "awk" is present in the provided essential packages
awk_in_provided=false
for pkg in "${essential_packages[@]}"; do
    if [ "$pkg" = "awk" ]; then
        awk_in_provided=true
        break
    fi
done

# Add "awk" to the provided essential packages if not present
if [ "$awk_in_provided" = false ]; then
    essential_packages+=("awk")
fi

apt-get update
apt-get install -y apt-rdepends 

# Read vulnerable package names from a file
while read -r package; do
    # Get the list of dependencies for the package
    dependencies=$(apt-rdepends "$package" | awk '/Depends:/ { print $2 }')
    dependencies+=$(apt-rdepends "$package" | awk '/PreDepends:/ { print $2 }')

    # Combine vulnerable package with its non-essential dependencies
    packages_to_remove=("$package")
    for dependency in $dependencies; do
        if ! printf '%s\n' "${essential_packages[@]}" | grep -q -P "^$dependency\$"; then
            packages_to_remove+=("$dependency")
        fi
    done

    # Perform package removal
    apt-get -y remove --allow-remove-essential --auto-remove "${packages_to_remove[@]}"
done < vulnerable-packages.txt

# Perform cleanup
apt-get -y autoremove
apt-get -y autoclean
apt-get -y remove --allow-remove-essential --auto-remove awk
