require IEx
defmodule Summarizer do
  use Application.Behaviour

  def start(_type, _args) do
    Summarizer.Supervisor.start_link
  end

  defrecord Activity, distance: 0, duration: 0, calories: 0, captured_at: nil
  defrecord ActivityGroup, group: nil
  defrecord Summary, total_distance: 0, total_duration: 0, calories_burned: 0, date: nil

  def summarize_from_json(activities_json) do
    {:ok, raw_activities} = JSON.decode(activities_json)
    activities = map_to_activities(raw_activities["activities"]) 
    activity_dates = extract_dates_from_activities(activities)
    group_by_date(activities, activity_dates) |>
    reduce_activity_group_to_summary
  end

  defp map_to_activities(activities) do
    Enum.map(activities, fn activity -> 
      Activity[
        distance: miles_to_meters(activity["distance"]),
        duration: activity["duration"],
        calories: activity["calories"],
        captured_at: Date.from(activity["captured_at"], :sec)
      ]
    end)
  end

  defp extract_dates_from_activities(activities) do
    Enum.map(activities, fn activity ->
      activity.captured_at.date
    end) |> Enum.uniq
  end

  defp group_by_date(activities, dates) do
    Enum.map(dates, fn date ->
      activities_for_date = Enum.filter(activities, fn activity -> activity.captured_at.date == date end)
      ActivityGroup[group: activities_for_date]
    end)
  end

  defp reduce_activity_group_to_summary(activity_groups) do
    Enum.map(activity_groups, fn(activity_group) ->
      Enum.map(activity_group.group, fn(activity) -> 
        Summary[
          total_distance: activity.distance,
          total_duration: activity.duration, 
          calories_burned: activity.calories,
          date: activity.captured_at
          ]
      end) |>
      Enum.reduce(fn(activity, acc)-> 
        Summary[
          total_distance: acc.total_distance + activity.total_distance,
          total_duration: acc.total_duration + activity.total_duration, 
          calories_burned: acc.calories_burned + activity.calories_burned, 
          date: activity.date
          ]
      end)
    end)
  end

  defp miles_to_meters(miles) do
    Kernel.binary_to_float(miles)*1609.34
  end
end
