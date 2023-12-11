use std::fs::read_to_string;
use std::cmp;

fn calc_move_direction(difference_x: i32, difference_y: i32) -> (i32, i32) {
    if difference_y == 0 {
        return if difference_x < 0 { (1, 0) } else { (-1, 0) };
    }
    if difference_x == 0 {
        return if difference_y < 0 { (0, 1) } else { (0, -1) };
    }

    return if difference_x < 0 { (1, 0) } else { (-1, 0) };
}

fn read_input_from_file(path: &'static str) -> Vec<String>{
    let full = read_to_string(path).unwrap();
    return full.lines().map(|line| {
        return line.to_owned();
    }).collect();
}

fn calc(lines: Vec<String>) -> usize {
    let mut galaxies: Vec<(usize, usize)> = Vec::new();
    let mut empty_rows: Vec<usize> = Vec::new();
    let mut empty_cols: Vec<usize> = Vec::new();

    // each row
    for (row, line) in lines.iter().enumerate() {
        let mut row_empty = true;
        for (col, c) in line.chars().enumerate() {
            if c == '#' {
                row_empty = false;
                galaxies.push((col, row));
            }
        }
        if row_empty {
            empty_rows.push(row);
        }
    }

    let width = lines.get(0).unwrap().len();
    // each col
    for col in 0..width {
        let mut col_empty = true;
        for galaxy in galaxies.iter() {
            if galaxy.0 == col {
                col_empty = false;
                break;
            }
        }
        if col_empty {
            empty_cols.push(col);
        }
    }

    const INC: usize = 1000000;

    let mut sum: usize = 0;
    for i in 0..galaxies.len() {
        for j in i+1..galaxies.len() {
            let g1 = galaxies.get(i).unwrap();
            let g2 = galaxies.get(j).unwrap();

            // 5 -> (1, 5)
            // 9 -> (4, 9)
            let mut steps = g2.0.abs_diff(g1.0) + (g2.1.abs_diff(g1.1));
            // go throught empty r,c
            for empty_row in empty_rows.iter() {
                let (min, max) = if g1.1 < g2.1 {(g1.1, g2.1)} else {(g2.1, g1.1)};
                if *empty_row > min && *empty_row < max {
                    steps += INC - 1;
                }
            }
            for empty_col in empty_cols.iter() {
                let (min, max) = if g1.0 < g2.0 {(g1.0, g2.0)} else {(g2.0, g1.0)};
                if *empty_col > min && *empty_col < max {
                    steps += INC - 1;
                }
            }

            //println!("({:?},{:?}) = {}", i + 1, j + 1, steps);
            sum += steps;
        }
    }

    return sum;
}

fn main() {
    let v = read_input_from_file("input_d11.txt");
    println!("{}", calc(v));
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn base_test() {
        let v = read_input_from_file("d11test.txt");
        let _ = calc(v);
    }
}

