cat \
  <(awk -v OFS="\t" '{ print $1, $2, $3, "hyper", "1000", ".", $2, $3, "0,0,255" }' $1) \
  <(awk -v OFS="\t" '{ print $1, $2, $3, "hypo", "1000", ".", $2, $3, "102,102,255" }' $2 \
| sort -T . -k1,1 -k2,2n > $3
