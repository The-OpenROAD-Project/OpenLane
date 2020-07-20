
for i in {0..15}; do
	export IDX=$i
	envsubst < a >> b
done
