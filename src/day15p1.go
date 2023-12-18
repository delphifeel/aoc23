package main

import (
	"bufio"
	"fmt"
	"os"
    "log"
	"strings"
)

func hash(s string) uint64 {
    res := uint64(0)

    for _, c := range s {
        code := uint64(c)
        res += code
        res *= 17
        res = res % 256
    }

    return res
}

func calc(line string) uint64 {
    steps := strings.Split(line, ",")
    sum := uint64(0)

    for _, step := range steps {
        sum += hash(step)
    }

    return sum
}

func main() {
    aocInput := readAocInput("input_d15.txt")
    fmt.Println(calc(aocInput[0]))
}


// ___ HELPERS ___
func readAocInput(fileName string) []string {
    file, err := os.Open(fileName)
    if err != nil {
        log.Fatal(err)
    }
    defer file.Close()

    res := []string{}
    scanner := bufio.NewScanner(file)
    for scanner.Scan() {
        res = append(res, scanner.Text())
    }

    if err := scanner.Err(); err != nil {
        log.Fatal(err)
    }
    return res
}
