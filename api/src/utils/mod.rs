use ring::digest as hasher;
use ring::rand::{SecureRandom, SystemRandom};

/// Various authentication-related utilities.
pub mod auth;
pub mod cors;
/// Utilities to issue logs about requests.
pub mod request_log;
/// Various utilities to assist building HTTP responses.
pub mod response;
pub mod sessions;

pub fn generate_id() -> String {
    let mut data = [0u8; 16];
    let rng = SystemRandom::new();
    rng.fill(&mut data).unwrap();

    self::generate_id_from_data(&data)
}

pub fn generate_id_from_data(data: &[u8]) -> String {
    let mut output = hex::encode(hasher::digest(&hasher::SHA512, data.as_ref()));
    output.truncate(16);
    output
}
