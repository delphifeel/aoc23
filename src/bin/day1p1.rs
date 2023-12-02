use std::fs::read_to_string;

fn read_input_from_file(path: &'static str) -> Vec<String> {
    let full = read_to_string(path).unwrap();
    return full.lines().map(String::from).collect();
}

fn calc_calibration(lines: &Vec<String>) -> usize {
    let mut sum: usize = 0;
    for line in lines {
        let mut first: char = '\0';
        let mut last: char = '\0';
        for c in line.chars() {
            if !c.is_ascii_digit() {
                continue;
            }

            // first digit found
            if first == '\0' {
                first = c;
                continue;
            }

            last = c;
        }
        if last == '\0' {
            last = first;
        }
        let n_as_str = format!("{}{}", first, last);
        sum += n_as_str.parse::<usize>().unwrap();
    }
    return sum;
}

fn main() {
    let v = read_input_from_file("input.txt");
    print!("calibration: {}\n", calc_calibration(&v));
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn base_test() {
        let v = read_input_from_file("test.txt");
        assert!(calc_calibration(&v) == 142);
    }
}

