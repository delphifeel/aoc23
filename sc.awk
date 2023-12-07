{
    for (i=0;i < length($1);i++) {
        sum = 0
        c = substr($1, i+1, 1)
        if (c == "J") {
            sum++
        }
        if (sum > 1) {
            print sum
        }
    }
}
