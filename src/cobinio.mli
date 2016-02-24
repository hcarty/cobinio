type 'elt kind =
    Char : char kind
  | Int8_signed : int kind
  | Int8_unsigned : int kind
  | Int16_signed : int kind
  | Int16_unsigned : int kind
  | Int32 : int32 kind
  | Int64 : int64 kind
  | Float32 : float kind
  | Float64 : float kind

type input = Lwt_io.input
type output = Lwt_io.output
type 'mode channel = 'mode Lwt_io.channel

type ('elt, 'mode) t

val little : (module EndianBytes.EndianBytesSig)
val big : (module EndianBytes.EndianBytesSig)
val native : (module EndianBytes.EndianBytesSig)

val make :
  'mode channel ->
  'elt kind ->
  (module EndianBytes.EndianBytesSig) ->
  int ->
  ('elt, 'mode) t

val get : ('elt, input) t -> int -> 'elt Lwt.t
val set : ('elt, output) t -> int -> 'elt -> unit Lwt.t
