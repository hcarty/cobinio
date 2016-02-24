let ( >>= ) = Lwt.( >>= )

let read input ~size ~offset =
  let buffer = Bytes.make size '.' in
  let byte_offset = offset * size in
  Lwt_io.set_position input (Int64.of_int byte_offset) >>= fun () ->
  Lwt_io.read_into_exactly input buffer 0 size >>= fun () ->
  Lwt.return buffer

let write output buffer ~offset =
  let size = Bytes.length buffer in
  let byte_offset = offset * size in
  Lwt_io.set_position output (Int64.of_int byte_offset) >>= fun () ->
  Lwt_io.write_from_exactly output buffer 0 size

type _ kind =
  | Char : char kind
  | Int8_signed : int kind
  | Int8_unsigned : int kind
  | Int16_signed : int kind
  | Int16_unsigned : int kind
  | Int32 : int32 kind
  | Int64 : int64 kind
  | Float32 : float kind
  | Float64 : float kind

let get_of_kind
    (type s)
    (module M : EndianBytes.EndianBytesSig)
    (kind : s kind)
  : (bytes -> int -> s) =
  match kind with
  | Char -> M.get_char
  | Int8_signed -> M.get_int8
  | Int8_unsigned -> M.get_uint8
  | Int16_signed -> M.get_int16
  | Int16_unsigned -> M.get_uint16
  | Int32 -> M.get_int32
  | Int64 -> M.get_int64
  | Float32 -> M.get_float
  | Float64 -> M.get_double

let set_of_kind
    (type s)
    (module M : EndianBytes.EndianBytesSig)
    (kind : s kind)
  : (bytes -> int -> s -> unit) =
  match kind with
  | Char -> M.set_char
  | Int8_signed -> M.set_int8
  | Int8_unsigned -> M.set_int8
  | Int16_signed -> M.set_int16
  | Int16_unsigned -> M.set_int16
  | Int32 -> M.set_int32
  | Int64 -> M.set_int64
  | Float32 -> M.set_float
  | Float64 -> M.set_double

let size_in_bytes (type s) (kind : s kind) =
  match kind with
  | Char -> 1
  | Int8_signed -> 1
  | Int8_unsigned -> 1
  | Int16_signed -> 2
  | Int16_unsigned -> 2
  | Int32 -> 4
  | Int64 -> 8
  | Float32 -> 4
  | Float64 -> 8

type input = Lwt_io.input
type output = Lwt_io.output
type 'mode channel = 'mode Lwt_io.channel

type reader = input channel -> size:int -> offset:int -> bytes Lwt.t
type writer = output channel -> bytes -> offset:int -> unit Lwt.t

type ('kind, 'mode) t = {
  endian : (module EndianBytes.EndianBytesSig);
  base_offset : int;
  kind : 'kind kind;
  src : 'mode channel;
}

let little = (module EndianBytes.LittleEndian : EndianBytes.EndianBytesSig)
let big = (module EndianBytes.BigEndian : EndianBytes.EndianBytesSig)
let native = (module EndianBytes.NativeEndian : EndianBytes.EndianBytesSig)

let make src kind endian base_offset =
  { src; kind; endian; base_offset }

let get t i =
  let size = size_in_bytes t.kind in
  let offset = t.base_offset + size * i in
  read t.src ~size ~offset >>= fun bytes ->
  Lwt.return @@ (get_of_kind t.endian t.kind) bytes 0

let set t i x =
  let size = size_in_bytes t.kind in
  let offset = t.base_offset + size * i in
  let buf = Bytes.create size in
  (set_of_kind t.endian t.kind) buf 0 x;
  write t.src buf ~offset
