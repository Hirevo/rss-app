use std::io;
use std::io::Write;

use env_logger::fmt::{Color, Formatter};
use log::{Level, Record};

fn info(fmt: &mut Formatter, record: &Record) -> io::Result<()> {
    let mut label = fmt.style();
    label.set_color(Color::Blue).set_bold(true);
    let mut target = fmt.style();
    target.set_bold(true);
    writeln!(
        fmt,
        "{}{}{} {}",
        label.value("info["),
        target.value(record.target()),
        label.value("]:"),
        record.args()
    )
}

fn warning(fmt: &mut Formatter, record: &Record) -> io::Result<()> {
    let mut label = fmt.style();
    label.set_color(Color::Yellow).set_bold(true);
    let mut target = fmt.style();
    target.set_bold(true);
    writeln!(
        fmt,
        "{}{}{} {}",
        label.value("warning["),
        target.value(record.target()),
        label.value("]:"),
        record.args()
    )
}

fn error(fmt: &mut Formatter, record: &Record) -> io::Result<()> {
    let mut label = fmt.style();
    label.set_color(Color::Red).set_bold(true);
    let mut target = fmt.style();
    target.set_bold(true);
    writeln!(
        fmt,
        "{}{}{} {}",
        label.value("error["),
        target.value(record.target()),
        label.value("]:"),
        record.args()
    )
}

fn debug(fmt: &mut Formatter, record: &Record) -> io::Result<()> {
    let mut label = fmt.style();
    label.set_color(Color::Magenta).set_bold(true);
    let mut target = fmt.style();
    target.set_bold(true);
    writeln!(
        fmt,
        "{}{}{} {}",
        label.value("debug["),
        target.value(record.target()),
        label.value("]:"),
        record.args()
    )
}

fn trace(fmt: &mut Formatter, record: &Record) -> io::Result<()> {
    let mut label = fmt.style();
    label.set_color(Color::Green).set_bold(true);
    let mut target = fmt.style();
    target.set_bold(true);
    writeln!(
        fmt,
        "{}{}{} {}",
        label.value("trace["),
        target.value(record.target()),
        label.value("]:"),
        record.args()
    )
}

/// Initialises the logging mechanisms.
pub fn init() {
    env_logger::builder()
        .parse_filters("")
        .format(|fmt, record| match record.level() {
            Level::Error => error(fmt, record),
            Level::Warn => warning(fmt, record),
            Level::Info => info(fmt, record),
            Level::Debug => debug(fmt, record),
            Level::Trace => trace(fmt, record),
        })
        .init();
}
