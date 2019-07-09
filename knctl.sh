# First download the knctl binary from: https://github.com/cppforlife/knctl/releases/tag/v0.3.0
hash=$(shasum -a 256 ~/Downloads/knctl-*);

if [hash = "382f075e8fdbf3cb33d6383149934cd3ebca2eb3b430e1a981f9575498f990b9"]
then
    mv ~/Downloads/knctl-* /usr/local/bin/knctl;
    chmod +x /usr/local/bin/knctl;
else
    echo "Hash check sums are not matching!"
fi    
