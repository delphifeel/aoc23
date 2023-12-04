use std::fs::read_to_string;
use std::cmp;

#[derive(Debug)]
struct Game {
    id: usize,
    red: Vec<usize>,
    green: Vec<usize>,
    blue: Vec<usize>,
    iter_count: usize,
}

// Game 1: 1 red, 10 blue, 5 green; 11 blue, 6 green; 6 green;
fn read_input_from_file(path: &'static str) -> Vec<Game> {
    let full = read_to_string(path).unwrap();
    return full.lines().map(|line| {
        let mut line_iter = line.split(&[':', ';']);
        let game_str = line_iter.nth(0).unwrap();
        let id = game_str.split(' ').nth(1).unwrap().parse().unwrap();

        let mut red: Vec<usize> = Vec::new();
        let mut green: Vec<usize> = Vec::new();
        let mut blue: Vec<usize> = Vec::new();
        let line_other = line_iter;
        let mut iter_count = 0;
        for token in line_other {
            iter_count += 1;
            for mut count_name in token.split(',') {
                count_name = count_name.trim();
                let mut cn_split = count_name.split(' ');
                let (count, name) = (cn_split.nth(0).unwrap(), cn_split.nth(0).unwrap());
                let count_v = count.parse::<usize>().unwrap();
                match name {
                    "red" => red.push(count_v),
                    "blue" => blue.push(count_v),
                    "green" => green.push(count_v),
                    _ => panic!(),
                }
            }
        }
        Game {
            id,
            red,
            blue,
            green,
            iter_count,
        }
    }).collect();
}

fn get_min(a: Option<usize>) -> usize {
    match a {
        Some(v) => v,
        None => 1,
    }
}

fn calc(v: Vec<Game>) -> usize {
    let mut sum = 0;

    for game in v {
        let r = game.red.into_iter().reduce(cmp::max);
        let g = game.green.into_iter().reduce(cmp::max);
        let b = game.blue.into_iter().reduce(cmp::max);

        sum += get_min(r) * get_min(g) * get_min(b);
    }

    return sum;
}

fn main() {
    let v = read_input_from_file("input_d2.txt");
    println!("{}", calc(v));
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn base_test() {
        let v = read_input_from_file("d2test.txt");
        let a = calc(v);
        assert!(a == 2286);
    }
}

