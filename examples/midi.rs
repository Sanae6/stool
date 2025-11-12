use std::{
  collections::{HashMap, HashSet},
  env::args,
  fs, iter::{once, repeat},
};

use embedded_time::{
  duration::{Duration, Extensions as DurationExtensions},
  rate::{Extensions as RateExtensions, Hertz},
};
use midly::{num::u7, MetaMessage, Smf, Timing, TrackEvent, TrackEventKind};

fn main() {
  let smf = fs::read(args().nth(1).unwrap()).unwrap();
  let smf = midly::Smf::parse(&smf).unwrap();

  let hz_per_tick = match smf.header.timing {
    Timing::Metrical(ticks_per_beat) => {
      let us_per_beat = smf
        .tracks
        .iter()
        .find_map(|trk| {
          trk.iter().find_map(|evt| {
            if let TrackEventKind::Meta(MetaMessage::Tempo(tempo)) = &evt.kind {
              Some(tempo.as_int().microseconds())
            } else {
              None
            }
          })
        })
        .expect("midi has not tempo on a metrical file");

      println!("metrical {ticks_per_beat}");
      let us_per_tick = us_per_beat / ticks_per_beat.as_int().into();
      println!(
        "{us_per_beat} {us_per_tick} {}",
        us_per_tick.to_rate::<Hertz>().unwrap()
      );

      us_per_tick.to_rate::<Hertz>().unwrap()
    }
    Timing::Timecode(fps, subframe) => {
      let hz_frame = (fps.as_int() as u32).Hz();
      let final_hz = hz_frame / subframe.into();
      println!("timecode {hz_frame} {subframe} {final_hz}");

      // final_hz
      todo!("test this");
    }
  };

  let mut events: Vec<(usize, u64, &TrackEvent)> = smf
    .tracks
    .iter()
    .enumerate()
    .flat_map(|(track, events)| {
      let mut ticks = 0u64;
      events
        .iter()
        .map(|event| {
          let cur_ticks = ticks;
          ticks += event.delta.as_int() as u64;
          (track, cur_ticks, event)
        })
        .collect::<Vec<_>>()
    })
    .collect::<Vec<_>>();
  events.sort_by_key(|(_, ticks, _)| *ticks);

  let mut voices = vec![];
  let mut active_notes = HashMap::new();
  let mut max_active = 0;
  for (track, ticks, event) in &events {
    let TrackEventKind::Midi { channel, message } = event.kind else {
      continue;
    };
    // println!("midi event {track} {channel} {message:?}");
    match message {
      midly::MidiMessage::NoteOff { key, vel: _ } => {
        if let Some(on) = active_notes.remove(&(channel, key)) {
          
        }
      }
      midly::MidiMessage::NoteOn { key, vel } => {
        active_notes.insert((channel, key), BuzzerOn {
          start_tick: 0,
          key,
          vel,
        });
      }
      _ => {}
    }
    max_active = max_active.max(active_notes.len());
    println!("active notes {}", active_notes.len());
  }
  
  println!("most notes active at a time {max_active}");
}

pub const BUZZER_COUNT: usize = 16;

struct BuzzerOn {
  start_tick: u32,
  key: u7,
  vel: u7,
}

struct Buzzers {
  buzzers: Vec<BuzzerOn>,
}

impl Buzzers {
  pub fn process_on(key: u8, velocity: u8) {
    if velocity >= 128 {
      panic!("this can't be real")
    }
  }
}
