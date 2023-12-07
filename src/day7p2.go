package main

import (
	"bufio"
	"log"
	"os"
	"strconv"
	"strings"
    "sort"
)

var cardsRank = []byte {
    'A', 'K', 'Q', 'T', 
    '9', '8', '7', '6', '5',
    '4', '3', '2', 'J',
}

func getCardRank(card byte) int {
    for i, r := range cardsRank {
        if r == card {
            return i
        }
    }
    panic("unreachagle")
}

type HandInfo struct {
    Cards string
    Power int
    Bid  int
}

func hasCount(cardToCount map[byte]int, toFind int) bool {
    for _, v := range cardToCount {
        if v == toFind {
            return true
        }
    }
    return false
}

func calcPower(cards string) int {
    // take a map of card to count
    cardToCount := map[byte]int {}
    for i := range cards {
        c := cards[i]
        _, ok := cardToCount[c]
        if !ok {
            cardToCount[c] = 1
        } else {
            cardToCount[c] += 1
        }
    }

    // actually calcing power
    mLen := len(cardToCount)

    // calc jokers
    jCount := 0
    v, ok := cardToCount['J']
    if ok {
        jCount = v
    }

    // five of a kind
    if mLen == 1 {
        return 7
    }
    if mLen == 2 {
        // four of a kind
        if hasCount(cardToCount, 4) {
            if jCount > 0 {
                return 7
            }
            return 6
        }
        
        // full house
        if jCount > 0 {
            return 7
        }
        return 5
    }
    if mLen == 3 {
        // three of a kind
        if hasCount(cardToCount, 3) {
            if jCount > 0 {
                return 6
            }
            return 4
        }
        
        // two pair
        if jCount == 2 {
            return 6
        }
        if jCount == 1 {
            return 5
        }

        return 3
    }
    if mLen == 4 {
        if jCount > 0 {
            return 4
        }
        // one pair
        return 2
    }
    // high card
    if jCount > 0 {
        return 2
    }
    return 1
}

func calc(lines []string) uint64 {
    hands := make([]HandInfo, 0, len(lines))
    for _, line := range lines {
        strs := strings.Split(line, " ")
        cardsStr := strs[0]
        bid, err := strconv.Atoi(strs[1])
        if err != nil {
            panic(err)
        }
        hands = append(hands, HandInfo{
            Cards: cardsStr,
            Bid: bid,
            Power: calcPower(cardsStr),
        })
    }

    sort.Slice(hands, func(i, j int) bool {
        a := hands[i]
        b := hands[j]
        if (a.Power < b.Power) {
            return true
        }
        if (b.Power < a.Power) {
            return false
        }

        // equal
        for i := range a.Cards {
            aCard := a.Cards[i]
            bCard := b.Cards[i]
            aRank := getCardRank(aCard)
            bRank := getCardRank(bCard)
            if aRank > bRank {
                return true
            }
            if bRank > aRank {
                return false
            }
        }
        return false
    })

    log.Printf("%v\n", hands)

    sum := uint64(0)
    for i, h := range hands {
        sum += uint64(h.Bid * (i + 1))
    }

    return sum
}

func main() {
    aocInput := readAocInput("input_d7.txt")
    log.Println(calc(aocInput))
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
