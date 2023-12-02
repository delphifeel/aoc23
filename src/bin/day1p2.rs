use std::{fs::read_to_string, collections::HashMap};

fn read_input_from_file(path: &'static str) -> Vec<String> {
    let full = read_to_string(path).unwrap();
    return full.lines().map(String::from).collect();
}

fn process_as_digit(c: char, first: &mut char, last: &mut char) {
    // first digit found
    if *first == '\0' {
        *first = c;
        return;
    }
    // set until last
    *last = c;
}

fn replace_all_words(line: String) -> String {
    let matches = [
        ("one".to_owned(), '1'),
        ("two".to_owned(), '2'),
        ("three".to_owned(), '3'),
        ("four".to_owned(), '4'),
        ("five".to_owned(), '5'),
        ("six".to_owned(), '6'),
        ("seven".to_owned(), '7'),
        ("eight".to_owned(), '8'),
        ("nine".to_owned(), '9'),
    ];

    let mut res = "".to_owned();
    let mut line_str = line.as_str();
    while line_str.chars().count() > 0 {
        let mut found = false;
        for (word, digit) in &matches {
            if line_str.starts_with(word) {
                res.push(*digit);
                break;
            }
        }

        if !found {
            let c = line_str.chars().nth(0).unwrap();
            res.push(c);
        }

        line_str = &line_str[1..];
    }
    return res;
}

fn calc_calibration(lines: Vec<String>) -> usize {
    let mut sum: usize = 0;
    for old_line in lines {
        dbg!(&old_line);
        let line = replace_all_words(old_line);
        dbg!(&line);
        let mut first: char = '\0';
        let mut last: char = '\0';
        for c in line.chars() {
            if c.is_ascii_digit() {
                process_as_digit(c, &mut first, &mut last);
                continue;
            }
        }

        if last == '\0' {
            last = first;
        }
        let n_as_str = format!("{}{}", first, last);
        let value: usize = n_as_str.parse().unwrap();
        dbg!(value);
        sum += value;
    }
    return sum;
}

fn main() {
    let v = read_input_from_file("input.txt");
    print!("calibration: {}\n", calc_calibration(v));
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn base_test() {
        let v = read_input_from_file("test.txt");
        assert!(calc_calibration(v) == 142);
    }

    #[test]
    fn p2_test() {
        let v = read_input_from_file("test2.txt");
        assert!(calc_calibration(v) == 281);
    }
}

