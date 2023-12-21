defmodule Day21 do
  @directions [{-1, 0}, {1, 0}, {0, -1}, {0, 1}]

  def part1(input, steps \\ 64) do
    solve(input, steps)
  end

  # The following tables were generated by running part2_print/3
  # (followed by some clean up).
  #
  # 2 * 131 + 65 steps
  #        932 5522  935
  #   932 6415 7335 6427 935
  #  5506 7335 7320 7335 5534
  #   937 6411 7335 6427 931
  #        937 5518  931

  # 4 * 131 + 65 steps
  #                  932 5522 935
  #             932 6415 7335 6427 935
  #        932 6415 7335 7320 7335 6427 935
  #   932 6415 7335 7320 7335 7320 7335 6427 935
  #  5506 7335 7320 7335 7320 7335 7320 7335 5534
  #   937 6411 7335 7320 7335 7320 7335 6427 931
  #        937 6411 7335 7320 7335 6427 931
  #             937 6411 7335 6427 931
  #                  937 5518 931

  # 6 * 131 + 65 steps
  #                           932 5522 935
  #                      932 6415 7335 6427 935
  #                 932 6415 7335 7320 7335 6427  935
  #            932 6415 7335 7320 7335 7320 7335 6427  935
  #       932 6415 7335 7320 7335 7320 7335 7320 7335 6427 935
  #  932 6415 7335 7320 7335 7320 7335 7320 7335 7320 7335 6427 935
  # 5506 7335 7320 7335 7320 7335 7320 7335 7320 7335 7320 7335 5534
  #  937 6411 7335 7320 7335 7320 7335 7320 7335 7320 7335 6427 931
  #       937 6411 7335 7320 7335 7320 7335 7320 7335 6427 931
  #            937 6411 7335 7320 7335 7320 7335 6427 931
  #                 937 6411 7335 7320 7335 6427 931
  #                      937 6411 7335 6427 931
  #                           937 5518  931
  #

  def part2(_input, steps \\ 26_501_365) do
    w = 131
    r = rem(steps, w)
    0 = rem(steps - r, 2)       # Assertion.
    n = div(steps - r, w)

    # Formulas derived with the help of WolframAlpha using the following
    # queries:
    #
    #    sum 1, 3, 5, 7
    #    sum 1, 2, 3, 4

    plots = 2 * n * n - (2 * n - 1)
    shorter = (n - 1) * n - (n - 1)
    longer = plots - shorter
    diagonals1 = n
    diagonals2 = n - 1
#    IO.inspect {n, plots, shorter, longer, diagonals1, diagonals2}
    shorter * 7320 + longer * 7335 +
    diagonals1 * (932 + 937 + 931 + 935) +
    diagonals2 * (6415 + 6411 + 6427 + 6427) +
    5522 + 5506 + 5518 + 5534
  end

  def part2_print(input, n, steps \\ 26_501_365) do
    {start, grid} = parse(input)
    positions = MapSet.new([start])
    Stream.iterate(positions, fn positions ->
      walk(grid, positions)
    end)
    |> Stream.drop(steps)
    |> Enum.take(1)
    |> hd
    |> then(fn seen ->
      -n..n
      |> Enum.flat_map(fn row ->
        -n..n
        |> Enum.map(fn col ->
          {row, col}
        end)
      end)
      |> Enum.map(fn {roffs, coffs} = offsets ->
        {offsets,
         seen
         |> filter_seen(grid, roffs, coffs)
         |> Enum.count}
      end)
      |> then(fn list ->
        Enum.chunk_every(list, 2 * n + 1)
        |> Enum.map(fn cols ->
          Enum.each(cols, fn {_,count} ->
            :io.format("~.6p ", [count])
          end)
          :io.nl
        end)
      end)
    end)
  end

  defp filter_seen(seen, {n, _}, roffs, coffs) do
    rr = roffs * n .. (roffs + 1) * n - 1
    cr = coffs * n .. (coffs + 1) * n - 1
    seen
    |> Enum.filter(fn {row, col} ->
      row in rr and col in cr
    end)
  end

  defp solve(input, steps) do
    {start, grid} = parse(input)
    positions = MapSet.new([start])
    Stream.iterate(positions, fn positions ->
      walk(grid, positions)
    end)
    |> Stream.drop(steps)
    |> Enum.take(1)
    |> hd
    |> MapSet.size
  end

  defp walk(grid, positions) do
    Enum.reduce(positions, MapSet.new(), fn position, seen ->
      Enum.reduce(@directions, seen, fn direction, seen ->
        new_pos = add(position, direction)
        case get_grid(grid, new_pos) do
          ?\# -> seen
          ?. -> MapSet.put(seen, new_pos)
        end
      end)
    end)
  end

  defp get_grid({n, grid}, {row, col}) do
    row = mod(row, n)
    col = mod(col, n)
    Map.fetch!(grid, {row, col})
  end

  defp mod(n, m) do
    case rem(n, m) do
      result when result < 0 -> result + m
      result -> result
    end
  end
  defp add({row0, col0}, {row1, col1}) do
    {row0 + row1, col0 + col1}
  end

  defp parse(input) do
    input
    |> Enum.with_index
    |> Enum.flat_map(fn {line, row} ->
      String.to_charlist(line)
      |> Enum.with_index
      |> Enum.flat_map(fn {char, col} ->
        position = {row, col}
        [{position, char}]
      end)
    end)
    |> Map.new
    |> then(fn map ->
      {max_row, _} = Enum.max_by(Map.keys(map), &elem(&1, 0))
      {_, max_col} = Enum.max_by(Map.keys(map), &elem(&1, 1))
      ^max_row = max_col
      {start, _} = Enum.find(map, fn {_, char} -> char === ?S end)
      map = Map.put(map, start, ?.)
      {start, {max_row + 1, map}}
    end)
  end

  def print_grid(seen, {n, map} = grid) do
    range = 0..n
    :io.nl
    Enum.each(range, fn row ->
      Enum.each(range, fn col ->
        position = {row, col}
        case MapSet.member?(seen, position) do
          true ->
            :io.put_chars("O")
          false ->
            case map do
              %{^position => item} ->
                :io.put_chars([item])
              %{} ->
                :io.put_chars(".")
            end
        end
      end)
      :io.nl
    end)
    :io.nl
    grid
  end
end
