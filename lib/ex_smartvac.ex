defmodule ExSmartvac do
  @json_string "[{\"room\": \"badi_example_room\", \"m\": 7, \"n\": 7, \"furniture_count\": 3, \"furniture\": [{\"name\": \"lamp\", \"start\": \"(0,3)\", \"end\": \"(0,3)\"}, {\"name\": \"bed\", \"start\": \"(1,1)\", \"end\": \"(1,4)\"}, {\"name\": \"desk\", \"start\": \"(4,4)\", \"end\": \"(5,5)\"}]}, {\"room\": \"second_room\", \"m\": 4, \"n\": 4, \"furniture_count\": 1, \"furniture\": [{\"name\": \"divider\", \"start\": \"(1,0)\", \"end\": \"(1,3)\"}]}]"

  def init(room_data) do
    if room_data != nil do
      empty_matrix = init_matrix(Map.get(room_data, "m"), Map.get(room_data, "n"))

      {populate_matrix(empty_matrix, Map.get(room_data, "furniture")), Map.get(room_data, "m"), Map.get(room_data, "n")}
    else
      {:error, "Room not found with that name"}
    end
  end

  def get_dead_ends(room_name) do
    all_rooms = JSON.decode!(@json_string)

    room_data = Enum.find(all_rooms, fn elem -> Map.get(elem, "room") == room_name end)

    {matrix, m, n} = init(room_data)

    exit_matrix = set_valid(matrix, 0, n-1)

    {solved_matrix, dead_ends} =
      Enum.reduce(0..n-1, {exit_matrix, 0}, fn row, acc1 ->
        Enum.reduce(m-1..0, acc1, fn col, {acc2, count2} ->
          if skipable_tile?(matrix, row, col) do
            {acc2, count2}
          else
            if invalid_top?(acc2, row, col) and invalid_right?(acc2, row, col) do
              {set_dead_end(acc2, row, col), count2 + 1}
            else
              {set_valid(acc2, row, col), count2}
            end
          end
        end)
      end)


    IO.inspect "#{room_name} have #{dead_ends} dead ends"
    solved_matrix
  end

  def get_all() do
    all_rooms = JSON.decode!(@json_string)

    Enum.each(all_rooms, fn room ->
      get_dead_ends(Map.get(room, "room"))
    end)
  end

  defp skipable_tile?(matrix, row, col) do
     {_, max_col} = Matrix.size(matrix)

    (row == 0 and col == max_col-1) or Matrix.elem(matrix, row, col) == 5
  end

  defp invalid_top?(matrix, row, col) do
    if row == 0 do
      true
    else
      Matrix.elem(matrix, row-1, col) in [1, 5]
    end
  end


  defp invalid_right?(matrix, row, col) do
    {_, max_col} = Matrix.size(matrix)

    if col == max_col-1 do
      true
    else
      Matrix.elem(matrix, row, col+1) in [1, 5]
    end
  end


  ### PRIV
  defp init_matrix(n, m) do
    Matrix.new(n, m)
  end

  defp populate_matrix(empty_matrix, list) do
    Enum.reduce(list, empty_matrix, fn piece, matrix ->
      {start_row, start_col} = Map.get(piece, "start") |> convert_string()
      {finish_row, finish_col} = Map.get(piece, "end") |> convert_string()

      Enum.reduce(start_row..finish_row, matrix, fn row, acc1 ->
        Enum.reduce(start_col..finish_col, acc1, fn col, acc2 ->
          Matrix.set(acc2, row, col, 5)
        end)
      end)
    end)
  end

  defp convert_string(string) do
    {String.at(string, 1) |> String.to_integer(), String.at(string, 3) |> String.to_integer()}
  end

  defp set_dead_end(matrix, row, col) do
    Matrix.set(matrix, row, col, 1)
  end


  defp set_valid(matrix, row, col) do
    Matrix.set(matrix, row, col, 2)
  end

end
