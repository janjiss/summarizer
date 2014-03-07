defmodule SummarizerTest do
  use ExUnit.Case

  def summary do
    json = '{"activities": [
        {
          "captured_at": 1392366463,
          "distance": "1.12",
          "duration": 12,
          "calories": 100

          },
        {
          "captured_at": 1392355727,
          "distance": "4.20",
          "duration": 80,
          "calories": 400

          },
        {
          "captured_at": 1392280163,
          "distance": "2.32",
          "duration": 20,
          "calories": 2200

          }

    ]}'
    [summary | tail] = Summarizer.summarize_from_json(json)
    summary
  end

  test "Summarizer" do
    assert(summary.total_distance == 8561.6888)
    assert(summary.total_duration == 92)
    assert(summary.calories_burned == 500) 
    assert(summary.date.date == {2014,2,14})
  end
end
