package main

import (
	"bufio"
	"fmt"
	"os"
)

type PointData struct {
    posX int64
    posY int64
    dirX int64
    dirY int64
}

type stack []PointData

func (s stack) push(v PointData, lines []string, visited [][]bool) stack {
    rows := len(lines)
    cols := len(lines[0])
    //fmt.Printf("v: %v\n", v)
    if v.posY == -1 || v.posY == int64(rows) {
        return s
    }
    if v.posX == -1 || v.posX == int64(cols) {
        return s
    }
    if visited[v.posY][v.posX] {
        return s
    }

    res := append(s, v)
    return res
}

func (s stack) pop() (stack, PointData) {
    l := len(s)

    if l == 0 {
        return nil, PointData{}
    }

    return  s[:l-1], s[l-1]
}


func traverse(lines []string) {
    toVisit := stack{}
    visited := alloc2dArray(int64(len(lines)), int64(len(lines[0])))

    toVisit = toVisit.push(PointData{
        posX: 0,
        posY: 0,
        dirX: 1,
        dirY: 0,
    }, lines, visited)
    var curr PointData
    var next PointData

    for {
        toVisit, curr = toVisit.pop()
        if toVisit == nil {
            break
        }
        visited[curr.posY][curr.posX] = true
        c := lines[curr.posY][curr.posX] - 48
        fmt.Printf("%v(%v, %v)\n", c, curr.posY, curr.posX)

        //fmt.Printf("%v(%v) -> ", c, curr)

        // rotate left
        next.dirX = -curr.dirY
        next.dirY = -curr.dirX
        next.posY = curr.posY + next.dirY
        next.posX = curr.posX + next.dirX

        toVisit = toVisit.push(next, lines, visited)

        // rotate right
        next.dirX = curr.dirY
        next.dirY = curr.dirX
        next.posY = curr.posY + next.dirY
        next.posX = curr.posX + next.dirX

        toVisit = toVisit.push(next, lines, visited)

/*        if steps < 3 {
            // go straight
            nextDir[0] = curr.dir[0]
            nextDir[1] = curr.dir[1]
            nextPos[0] = curr.posY + nextDir[0]
            nextPos[1] = curr.posX + nextDir[1]
            v, done = traverse(proceed, lines, nextPos, nextDir, steps+1)
            if done {
                sums[sumsLen] += v
                sumsLen += 1
            }
        }
  */
    }
}

func calc(lines []string) uint64 {
    traverse(lines)
	return 0
}

func main() {
	aocInput := readAocInput("d17temp.txt")
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

func readAocInput(fileName string) []string {
	file, err := os.Open(fileName)
	if err != nil {
		panic(err)
	}
	defer file.Close()

	res := []string{}
	scanner := bufio.NewScanner(file)
	for scanner.Scan() {
		res = append(res, scanner.Text())
	}

	if err := scanner.Err(); err != nil {
		panic(err)
	}
	return res
}
