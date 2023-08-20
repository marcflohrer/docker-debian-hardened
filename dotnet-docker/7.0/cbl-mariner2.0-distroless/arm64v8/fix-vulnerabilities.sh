apt-get update \
&& apt-get -y upgrade \
&& apt-get -y dist-upgrade \
&& chmod +x remove-rdepends-of-vuln-pckgs.sh \
&& ./remove-rdepends-of-vuln-pckgs.sh "glibc,krb5,libgcc,libstdc++,openssl-libs,zlib" \
&& xargs -r -a vulnerable-packages.txt apt-get -y remove --allow-remove-essential --auto-remove \
&& apt-get -y autoremove \
&& apt-get -y autoclean \
&& rm /vulnerable-packages.txt