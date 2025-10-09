use std::{
  fs::{File, write},
  io::BufReader,
  path::PathBuf,
};

use image::{EncodableLayout, ImageReader};

fn main() {
  let image = PathBuf::from(std::env::args().nth(1).unwrap());
  println!("{image:?}");
  let mut r = ImageReader::new(BufReader::new(File::open(image).unwrap()));
  r.set_format(image::ImageFormat::Png);
  let image = r.decode().unwrap().into_rgb8();
  println!(
    "{:X} {:X} {:X} {}",
    image.len(),
    image.width() * image.height() * 3,
    image.width() * image.height(),
    image.width()
  );
  write("src/me.bytes", image.as_bytes()).unwrap();
}
