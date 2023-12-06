package main

import (
	"bufio"
	"log"
	"os"
	"strconv"
	"strings"
    "math"
)

func readAocInput(fileName string) []string {
    file, err := os.Open(fileName)
    if err != nil {
        log.Fatal(err)
    }
    defer file.Close()

    res := []string{}
    scanner := bufio.NewScanner(file)
    // optionally, resize scanner's capacity for lines over 64K, see next example
    for scanner.Scan() {
        res = append(res, scanner.Text())
    }

    if err := scanner.Err(); err != nil {
        log.Fatal(err)
    }
    return res
}

func calc_high(timeU uint64, distanceU uint64) uint64 {
    time := float64(timeU)
	distance := float64(distanceU)
	a1 := time*time - 4.0*distance - 4.0
	r := (time + math.Sqrt(a1)) / 2
    
    return uint64(math.Floor(r))
}

func calc_low(timeU uint64, distanceU uint64) uint64 {
    time := float64(timeU)
	distance := float64(distanceU)
	a1 := time*time - 4.0*distance - 4.0
	r := (time - math.Sqrt(a1)) / 2
    
    return uint64(math.Ceil(r))
}

func calc(lines []string) uint64 {
    // prepare data
    timeStr := ""
    recordStr := ""

    sl := strings.Split(lines[0], ":")
    s := sl[1]
    sl = strings.Split(s, " ")
    for _, nStr := range sl {
        log.Printf("[%v]\n", nStr)
        timeStr += nStr
    }

    sl = strings.Split(lines[1], ":")
    s = sl[1]
    sl = strings.Split(s, " ")
    for _, nStr := range sl {
        log.Printf("[%v]\n", nStr)
        recordStr += nStr
    }

    // actually algo
    sum := uint64(0)
    distance, err := strconv.ParseUint(recordStr, 10, 64)
    if err != nil {
        panic(err)
    }
    time, err := strconv.ParseUint(timeStr, 10, 64)
    if err != nil {
        panic(err)
    }

    low := calc_low(time, distance)
    high := calc_high(time, distance)
    diff := high - low + 1
    if sum == 0 {
        sum = diff
    } else {
        sum *= diff
    }
    return sum
}

func main() {
    aocInput := readAocInput("input_d6.txt")
    log.Println(calc(aocInput))
}
