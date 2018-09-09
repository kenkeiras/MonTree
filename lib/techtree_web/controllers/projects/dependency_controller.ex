defmodule TechtreeWeb.Projects.DependencyController do
  use TechtreeWeb, :controller

  alias Techtree.Projects
  alias Techtree.Projects.Step
  alias TechtreeWeb.Projects.ProjectController

  alias TechtreeWeb.Projects.Plugs

  plug :require_existing_contributor
  plug :authorize_page

  defp require_existing_contributor(conn, x) do
    # TODO move to it's own module
    ProjectController.require_existing_contributor(conn, x)
  end

  defp authorize_page(conn, x) do
    ProjectController.authorize_page(conn, x)
  end

  def get_available_dependencies_for_step(conn, step) do
    all_steps = Projects.list_steps_in_project(conn.assigns.project)
    others_used = (for dep <- step.dependencies, do: dep.id) |> Enum.into(HashSet.new)
    used = HashSet.put(others_used, step.id)

    for other_step <- all_steps,
                      !(HashSet.member?(used, other_step.id)),
                      do: {other_step.title, other_step.id}

  end

  def new(conn, %{"step_id" => step_id}) do
    step = Projects.get_step_with_dependencies!(step_id)
    available_steps = get_available_dependencies_for_step(conn, step)

    render(conn, "new.html", step: step, available_steps: available_steps)
  end

  def create(conn, %{"dependency" => depended_id, "step_id" => step_id}) do
    step = Projects.get_step_with_dependencies!(step_id)
    depended = Projects.get_step!(depended_id)

    case Projects.create_dependency(depended, step) do
      %Step{} ->
        conn
        |> put_flash(:info, "Dependency added successfully.")
        |> redirect(to: project_step_path(conn, :show, conn.assigns.project.id, step_id))
      {:error, %Ecto.Changeset{} = changeset} ->
        IO.puts("ERROR:")
        IO.inspect(changeset)

        available_steps = get_available_dependencies_for_step(conn, step)
        render(conn, "new.html", step: step,
                                 available_steps: available_steps, 
                                 changeset: changeset)
    end
  end

  def delete(conn, %{"step_id" => step_id, "dependency_id" => dependency_id}) do
    {depender_id, ""} = Integer.parse(step_id)
    {depended_id, ""} = Integer.parse(dependency_id)
    {:ok, %Postgrex.Result{ num_rows: 1 }} = Projects.delete_dependency(depender_id, depended_id)

    conn
    |> put_flash(:info, "Dependency deleted successfully.")
    |> redirect(to: project_project_path(conn, :show, conn.assigns.project.id))
  end

  def dependency_graph(conn, _params) do
    dependency_graph = Projects.get_dependency_graph(conn.assigns.project)

    render(conn, "dependency_graph.json", graph: dependency_graph)
  end

  def get_step_dependencies(conn, %{"step_id" => step_id, "project_id" => project_id}) do
    step = Projects.get_step_with_dependencies!(step_id)
    available_steps = get_available_dependencies_for_step(conn, step)

    render(conn, "steps.json", %{steps: available_steps})
  end

  def add_dependency(conn, %{
                              "step_id" => step_id,
                              "project_id" => project_id,
                              "depended_id" => depended_id
                            }) do
    step = Projects.get_step_with_dependencies!(step_id)
    depended = Projects.get_step!(depended_id)

    case Projects.create_dependency(depended, step) do
      %Step{} ->
        render(conn, "result.json", %{result: %{ success: true }})
      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_status(:bad_request)
        |> render("result.json", %{result: %{ success: false}})
      end
  end


  def remove_dependency(conn, %{
                              "step_id" => step_id,
                              "project_id" => project_id,
                              "depended_id" => dependency_id
                            }) do
    {depender_id, ""} = Integer.parse(step_id)
    {depended_id, ""} = Integer.parse(dependency_id)
    {:ok, %Postgrex.Result{ num_rows: 1 }} = Projects.delete_dependency(depender_id, depended_id)

    render(conn, "result.json", %{result: %{ success: true }})
  end
end
