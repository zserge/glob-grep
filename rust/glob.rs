use std::env;
use std::io::BufRead;
use std::path::Path;
use std::{fs, io};

fn glob(pattern: &[u8], text: &[u8]) -> bool {
    let mut p: usize = 0;
    let mut t: usize = 0;
    let mut np: usize = 0;
    let mut nt: usize = 0;
    while p < pattern.len() || t < text.len() {
        if p < pattern.len() {
            match pattern[p] as char {
                '*' => {
                    np = p;
                    nt = t + 1;
                    p += 1;
                    continue;
                }
                '?' => {
                    if nt < text.len() {
                        p += 1;
                        t += 1;
                        continue;
                    }
                }
                _ => {
                    if t < text.len() && text[t] == pattern[p] {
                        p += 1;
                        t += 1;
                        continue;
                    }
                }
            }
        }
        if nt > 0 && nt <= text.len() {
            p = np;
            t = nt;
            continue;
        }
        return false;
    }
    true
}

fn walk(dir: &Path, pattern: &str) -> io::Result<()> {
    for entry in fs::read_dir(dir)? {
        let path = entry?.path();
        if path.is_dir() {
            walk(&path, &pattern)?;
            continue;
        }
        let file = fs::File::open(&path)?;
        let reader = io::BufReader::new(file);
        let mut lineno = 0;
        for line in reader.lines() {
            lineno += 1;
            let line = match line {
                Ok(s) => s,
                Err(_) => "".to_string(),
            };
            if glob(pattern.as_bytes(), line.as_bytes()) {
                println!("{}:{}\t{}", path.to_str().unwrap_or(""), lineno, line);
            }
        }
    }
    Ok(())
}

pub fn main() {
    let argv: Vec<String> = env::args().collect();
    if argv.len() != 2 {
        println!("USAGE: glob <pattern>");
        return;
    }
    match walk(Path::new("."), &argv[1]) {
        Ok(()) => (),
        Err(error) => panic!("Error: {:?}", error),
    };
}

#[cfg(test)]
mod test {
    use super::glob;
    #[test]
    fn test_glob() {
        assert!(glob(b"", b""));
        assert!(glob(b"hello", b"hello"));
        assert!(glob(b"h??lo", b"hello"));
        assert!(glob(b"h*o", b"hello"));
        assert!(glob(b"h*ello", b"hello"));
        assert!(glob(b"*h*o*", b"hello world"));
        assert!(glob(b"h*o*", b"hello world"));
        assert!(glob(b"*h*d", b"hello world"));
        assert!(glob(b"*h*l*w*d", b"hello world"));
        assert!(glob(b"*h?l*w*d", b"hello world"));

        assert!(!glob(b"hello", b"hi"));
        assert!(!glob(b"h?i", b"hi"));
        assert!(!glob(b"h*l", b"hello"));
    }
}
