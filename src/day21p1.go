package main

import (
	"bufio"
	"fmt"
	"os"
)

func isPosAvailable(pos [2]int64, lines [][]byte, visited [][]bool) bool {
    rows := len(lines)
    cols := len(lines[0])

    if pos[0] == -1 || pos[0] == int64(rows) {
        return false
    }
    if pos[1] == -1 || pos[1] == int64(cols) {
        return false
    }
    if visited[pos[0]][pos[1]] {
        return false
    }
    if lines[pos[0]][pos[1]] == '#' {
        return false
    }
    return true
}

const SIZE = 4000

func process(q [][2]int64, qLenPtr *int, curr [2]int64, lines [][]byte, visited [][]bool, finalPos [][]bool,
             stepsLeft uint64) {
    visited[curr[0]][curr[1]] = true
    if stepsLeft % 2 == 0 {
        finalPos[curr[0]][curr[1]] = true
    }

    newCurr := [2]int64{curr[0] - 1, curr[1]}
    qLen := *qLenPtr
    if isPosAvailable(newCurr, lines, visited) {
        q[qLen] = newCurr
        qLen += 1
        if stepsLeft == 1 {
            finalPos[newCurr[0]][newCurr[1]] = true
        }
    }
    newCurr = [2]int64{curr[0], curr[1] + 1}
    if isPosAvailable(newCurr, lines, visited) {
        q[qLen] = newCurr
        qLen += 1
        visited[newCurr[0]][newCurr[1]] = true
        if stepsLeft == 1 {
            finalPos[newCurr[0]][newCurr[1]] = true
        }
    }
    newCurr = [2]int64{curr[0] + 1, curr[1]}
    if isPosAvailable(newCurr, lines, visited) {
        q[qLen] = newCurr
        qLen += 1
        visited[newCurr[0]][newCurr[1]] = true
        if stepsLeft == 1 {
            finalPos[newCurr[0]][newCurr[1]] = true
        }
    }
    newCurr = [2]int64{curr[0], curr[1] - 1}
    if isPosAvailable(newCurr, lines, visited) {
        q[qLen] = newCurr
        qLen += 1
        visited[newCurr[0]][newCurr[1]] = true
        if stepsLeft == 1 {
            finalPos[newCurr[0]][newCurr[1]] = true
        }
    }
    *qLenPtr = qLen
}


func calc(lines [][]byte) uint64 {
    pos := [2]int64{0, 0}
    for row, line := range lines {
        for col, c := range line {
            if c == 'S' {
                pos = [2]int64{int64(row), int64(col)}
                break
            }
        }
    }

    visited := alloc2dArray(int64(len(lines)), int64(len(lines[0])))
    finalPos := alloc2dArray(int64(len(lines)), int64(len(lines[0])))
    stepsLeft := uint64(64)

    q := make([][2]int64, SIZE)
    q[0] = pos
    qLen := 1
    qPos := 0
    newQ := make([][2]int64, SIZE)
    newQLen := 0
    for stepsLeft > 0 {
        for qLen > 0 {
            curr := q[qPos]
            qPos += 1
            qLen -= 1
            process(newQ, &newQLen, curr, lines, visited, finalPos, stepsLeft)
        }
        
        for i := 0; i < newQLen; i++ {
            q[i] = newQ[i]
        }
        qLen = newQLen
        newQLen = 0
        qPos = 0

        stepsLeft -= 1
    }

    sum := uint64(0)
    for y, v := range finalPos {
        for x, ok := range v {
            if ok {
                lines[y][x] = '0'
                sum += 1
            }
        }
    }


    for _, l := range lines {
        for _, c := range l {
            fmt.Printf("%c", c)
        }
        fmt.Println()
    }

    return sum
}

func main() {
	aocInput := readAocInput("input_d21.txt")
	fmt.Println(calc(aocInput))
}

// ___ HELPERS ___
func alloc2dArray(rows int64, cols int64) [][]bool {
	res := make([][]bool, rows)
	for i := int64(0); i < rows; i++ {
		res[i] = make([]bool, cols)
		for j := int64(0); j < cols; j++ {
			res[i][j] = false
		}
	}
	return res
}

func readAocInput(fileName string) [][]byte {
	file, err := os.Open(fileName)
	if err != nil {
		panic(err)
	}
	defer file.Close()

	res := [][]byte{}
	scanner := bufio.NewScanner(file)
	for scanner.Scan() {
		res = append(res, []byte(scanner.Text()))
	}

	if err := scanner.Err(); err != nil {
		panic(err)
	}
	return res
}
