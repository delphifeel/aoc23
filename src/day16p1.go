package main

import (
	"bufio"
	"log"
	"os"
    "fmt"
)

func process(lines [][]byte, pos []int64, dir []int64, proceed [][]bool, energized [][]bool) {
    rowsCount := int64(len(lines))
    colsCount := int64(len(lines[0]))
    temp := int64(0)

    for {
        y := pos[0]
        x := pos[1]
        if x == colsCount || x == -1 {
            break
        }
        if y == rowsCount || y == -1 {
            break
        }
        c := lines[y][x]
        if proceed[y][x] {
            break
        }
        switch c {
        case '/':
            temp = dir[0]
            dir[0] = -dir[1]
            dir[1] = -temp
        case '\\':
            temp = dir[0]
            dir[0] = dir[1]
            dir[1] = temp
        case '-':
            if dir[0] != 0 {
                dir[0] = 0
                dir[1] = 1
                proceed[y][x] = true
                process(lines, []int64{y, x - 1}, []int64{0, -1}, proceed, energized)
            }
        case '|':
            if dir[1] != 0 {
                dir[0] = 1
                dir[1] = 0
                proceed[y][x] = true
                process(lines, []int64{y - 1, x}, []int64{-1, 0}, proceed, energized)
            }
        }

        energized[y][x] = true

        pos[0] = pos[0] + dir[0]
        pos[1] = pos[1] + dir[1]
    }
}

func calc(lines [][]byte) uint64 {
    pos := [2]int64{0, 0}
    dir := [2]int64{0, 1}
    proceed := alloc2dArray(uint64(len(lines)), uint64(len(lines[0])))
    energized := alloc2dArray(uint64(len(lines)), uint64(len(lines[0])))
    process(lines, pos[:], dir[:], proceed, energized)

    sum := uint64(0)
    for y := 0; y < len(energized); y++ {
        for x := 0; x < len(energized[0]); x++ {
            if energized[y][x] {
                sum += 1
            }
        }
    }

    return sum
}

func main() {
    aocInput := readAocInput("input_d16.txt")
    fmt.Println(calc(aocInput))
}

func printAoc(lines [][]byte, proceed [][]bool) {
    for y, bytes := range lines {
        for x, b := range bytes {
            if proceed[y][x] {
                fmt.Printf("%c", '#')
            } else {
                fmt.Printf("%c", b)
            }
        }
        fmt.Println()
    }
}

func alloc2dArray(rows uint64, cols uint64) [][]bool {
    res := make([][]bool, rows)
    for i := uint64(0); i < rows; i++ {
        res[i] = make([]bool, cols)
        for j := uint64(0); j < cols; j++ {
            res[i][j] = false
        }
    }
    return res
}

// ___ HELPERS ___
func readAocInput(fileName string) [][]byte {
    file, err := os.Open(fileName)
    if err != nil {
        log.Fatal(err)
    }
    defer file.Close()

    res := [][]byte{}
    scanner := bufio.NewScanner(file)
    for scanner.Scan() {
        res = append(res, []byte(scanner.Text()))
    }

    if err := scanner.Err(); err != nil {
        log.Fatal(err)
    }
    return res
}
