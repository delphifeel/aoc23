package main

import (
	"bufio"
	"fmt"
	"log"
	"os"
	"slices"
	"sync"
)

func process(lines []string, pos [2]int64, dir [2]int64, proceed [][]bool, energized [][]bool) {
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
				process(lines, [2]int64{y, x - 1}, [2]int64{0, -1}, proceed, energized)
			}
		case '|':
			if dir[1] != 0 {
				dir[0] = 1
				dir[1] = 0
				proceed[y][x] = true
				process(lines, [2]int64{y - 1, x}, [2]int64{-1, 0}, proceed, energized)
			}
		}

		energized[y][x] = true

		pos[0] = pos[0] + dir[0]
		pos[1] = pos[1] + dir[1]
	}
}

var mutex sync.Mutex
var allSum []uint64

func calcFrom(lines []string, pos [2]int64, dir [2]int64) {
	proceed := alloc2dArray(uint64(len(lines)), uint64(len(lines[0])))
	energized := alloc2dArray(uint64(len(lines)), uint64(len(lines[0])))
	process(lines, pos, dir, proceed, energized)
	//fmt.Printf("calcFrom pos: %v, dir: %v\n", pos, dir)
	calcSum(energized)
}

func calc(lines []string) {
	allSum = make([]uint64, 0)
	rows := int64(len(lines))
	cols := int64(len(lines[0]))
	var wg sync.WaitGroup

	// top-bottom lines
	for i := int64(0); i < cols; i++ {
		wg.Add(1)
		i := i
		go func() {
			calcFrom(lines, [2]int64{0, i}, [2]int64{1, 0})
			calcFrom(lines, [2]int64{rows - 1, i}, [2]int64{-1, 0})
			wg.Done()
		}()
	}
	// right-left lines
	for i := int64(0); i < rows; i++ {
		wg.Add(1)
		i := i
		go func() {
			calcFrom(lines, [2]int64{i, 0}, [2]int64{0, 1})
			calcFrom(lines, [2]int64{i, cols - 1}, [2]int64{0, -1})
			wg.Done()
		}()
	}

	wg.Wait()
	fmt.Printf("%v\n", slices.Max(allSum))
}

func calcSum(energized [][]bool) {
	sum := uint64(0)
	for y := 0; y < len(energized); y++ {
		for x := 0; x < len(energized[0]); x++ {
			if energized[y][x] {
				sum += 1
			}
		}
	}
	mutex.Lock()
	defer mutex.Unlock()
	allSum = append(allSum, sum)
}

func main() {
	aocInput := readAocInput("input_d16.txt")
	calc(aocInput)
}

func printAoc(lines []string, proceed [][]bool) {
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
