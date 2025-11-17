use std::error::Error;
use std::result::Result;

use axum::{
    routing::get, Router
};

#[tokio::main]
async fn main() -> Result<(), Box< dyn Error >>{
    let app = Router::new().route("/", get(|| async { "Hello, World!" }));

    let listener = tokio::net::TcpListener::bind("0.0.0.0:3000").await.unwrap();

    axum::serve(listener, app).await.unwrap();

    Ok(())
}
