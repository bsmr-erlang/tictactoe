defmodule Tictac do
  use Application

  def start(_type, port) do
    import Supervisor.Spec

    children = [
      # Tictac.Game.start_link([name: :game_server])
      worker(Tictac.Game, [[name: :game_server]]),

      # Task.Supervisor.start_link([name: :players_supervisor])
      supervisor(Task.Supervisor, [[name: :players_supervisor]]),

      # Task.start_link(Tictac.Server, :accept, [port])
      worker(Task, [Tictac.Server, :accept, [port]])
    ]

    Supervisor.start_link(children, strategy: :rest_for_one)
  end
end
