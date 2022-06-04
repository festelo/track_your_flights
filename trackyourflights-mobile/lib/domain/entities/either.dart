class Either<T, TError> {
  const Either.value(this.value) : error = null;
  const Either.error(this.error) : value = null;
  const Either.empty()
      : error = null,
        value = null;

  final T? value;
  final TError? error;
}

class Or<TFirst, TSecond> {
  const Or.first(this.first) : second = null;
  const Or.second(this.second) : first = null;

  final TFirst? first;
  final TSecond? second;
}
