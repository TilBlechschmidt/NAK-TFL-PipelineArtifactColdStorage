use std::io::prelude::*;
use std::{fs, fs::File, io};
use zstd::block::Compressor;

fn evaluate_compression(
    block_size: u64,
    level: i32,
    use_dictionary: bool,
) -> Result<(usize, usize, usize), io::Error> {
    let mut f = File::open("small.tar")?;
    let mut buffer = Vec::new();
    let mut compressor = if use_dictionary {
        Compressor::with_dict(fs::read("dictionary")?)
    } else {
        Compressor::new()
    };

    // let size = f.metadata()?.len();

    let mut uncompressed_count = 0;
    let mut compressed_count = 0;
    let mut block_count = 0;
    loop {
        let reference = std::io::Read::by_ref(&mut f);

        buffer.clear();
        let count = reference
            .take(block_size * 1024 * 1024)
            .read_to_end(&mut buffer)?;

        if count == 0 {
            break;
        }

        let compressed = compressor.compress(&buffer, level)?;

        block_count += 1;
        uncompressed_count += count;
        compressed_count += compressed.len();
    }

    Ok((compressed_count, uncompressed_count, block_count))
}

fn main() -> Result<(), io::Error> {
    let mut csv = File::create("blocked_results.csv")?;

    writeln!(
        csv,
        "block_size,level,regular,dict,uncompressed,block_count"
    )?;

    for block_size in vec![1, 2, 4, 8, 16, 32] {
        for level in 1..20 {
            println!("Processing block size {}, level {}", block_size, level);
            let without_dict = evaluate_compression(block_size, level, false)?;
            let with_dict = evaluate_compression(block_size, level, true)?;

            assert_eq!(without_dict.1, with_dict.1);
            assert_eq!(without_dict.2, with_dict.2);

            writeln!(
                csv,
                "{},{},{},{},{},{}",
                block_size, level, without_dict.0, with_dict.0, without_dict.1, without_dict.2
            )?;
        }
    }

    csv.flush()?;

    // let mut f = File::open("input.tar")?;
    // let mut out = File::create("output.blocked.dict.zstd")?;
    // let dict = fs::read("dictionary")?;

    // let mut compressor = Compressor::with_dict(dict);

    // // let mut buffer = Vec::with_capacity(16 * 1024 * 1024);

    // // loop {
    // let mut buffer = Vec::new();

    // loop {
    //     let reference = std::io::Read::by_ref(&mut f);

    //     // read at most 5 bytes
    //     buffer.clear();
    //     let count = reference.take(16 * 1024 * 1024).read_to_end(&mut buffer)?;

    //     if count == 0 {
    //         println!("Read 0 bytes");
    //         break;
    //     }

    //     let compressed = compressor.compress(&buffer, 19)?;
    //     println!("{} {}", count, compressed.len());
    //     out.write(&compressed)?;
    // }

    // out.flush()?;

    // match input.read(&mut buffer[..]) {
    //     Ok(count) => {
    //         println!("Read {} bytes", count);
    //     }
    //     Err(e) => {
    //         eprintln!("{:?}", e);
    //         break;
    //     }
    // }
    // }

    Ok(())
}
