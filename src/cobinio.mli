(** {1 mmap-like IO} *)

type 'elt kind =
  | Char : char kind
  | Int8_signed : int kind
  | Int8_unsigned : int kind
  | Int16_signed : int kind
  | Int16_unsigned : int kind
  | Int32 : int32 kind
  | Int64 : int64 kind
  | Float32 : float kind
  | Float64 : float kind
  (** Type of values to read/write *)

type input = Lwt_io.input
type output = Lwt_io.output
type 'mode channel = 'mode Lwt_io.channel

type ('elt, 'mode) t
(** Sources with values of type ['elt] and ['mode] permissions. *)

val little : (module EndianBytes.EndianBytesSig)
val big : (module EndianBytes.EndianBytesSig)
val native : (module EndianBytes.EndianBytesSig)
(** Endianness of values read/written *)

val make :
  'mode channel ->
  'elt kind ->
  (module EndianBytes.EndianBytesSig) ->
  int ->
  ('elt, 'mode) t
(** [make chan kind endian offset] wraps [chan] so that it is accessed as if it
    is a contiguous sequence of [kind] elements.  [endian] indicates the
    endianness of the data in [chan].

    @param offset indicates how many bytes to skip at the start of the file, if
    there's a header at the start of the file. *)

val get : ('elt, input) t -> int -> 'elt Lwt.t
(** [get src i] returns the [i]th value from [src]. *)

val set : ('elt, output) t -> int -> 'elt -> unit Lwt.t
(** [set src i v] sets the [i]th value in [src] to [v]. *)
