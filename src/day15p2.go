package main

import (
	"bufio"
	"fmt"
	"log"
	"os"
	"strconv"
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

type boxItem struct {
    id string
    value uint
}

func calc(line string) uint64 {
    steps := strings.Split(line, ",")
    boxes := [256][]boxItem{}
    sum := uint64(0)
    id := ""
    value := uint(0)

    for _, step := range steps {
        data := strings.Split(step, "=")
        if len(data) == 1 {
            // jls-
            id = data[0][:len(data[0])-1]

            // remove it
            h := hash(id)
            box := boxes[h]
            for i := range box {
                if box[i].id == id {
                    box = append(box[:i], box[i+1:]...)
                    boxes[h] = box
                    break
                }
            }
        } else {
            id = data[0]
            value64, err := strconv.ParseUint(data[1], 10, 0)
            if err != nil {
                panic(err)
            }
            value = uint(value64)

            // add/update
            h := hash(id)
            box := boxes[h]
            found := false
            for i := range box {
                if box[i].id == id {
                    found = true
                    box[i].value = value
                    break
                }
            }
            if !found {
                box = append(box, boxItem{id, value})
                boxes[h] = box
            }
        }
    }

    for i, box := range boxes {
        for j := range box {
            sum += uint64(i+1) * uint64(j+1) * uint64(box[j].value)
        }
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
