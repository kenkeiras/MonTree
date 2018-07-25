defmodule TechtreeWeb.Projects.StepController do
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

  def index(conn, _params) do
    steps = Projects.list_steps_in_project(conn.assigns.project)
    IO.inspect(steps)
    render(conn, "index.html", project: conn.assigns.project, steps: steps)
  end

  def new(conn, _params) do
    changeset = Projects.change_step(%Step{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"step" => step_params}) do
    case Projects.create_step(conn.assigns.current_contributor, conn.assigns.project, step_params) do
      {:ok, step} ->
        conn
        |> put_flash(:info, "Step created successfully.")
        |> redirect(to: project_step_path(conn, :show, conn.assigns.project.id, step))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"step_id" => id}) do
    step = Projects.get_step!(id)
    render(conn, "show.html", step: step)
  end

  def edit(conn, %{"step_id" => id}) do
    step = Projects.get_step!(id)
    changeset = Projects.change_step(step)
    render(conn, "edit.html", step: step, changeset: changeset)
  end

  def update(conn, %{"step_id" => id, "step" => step_params}) do
    step = Projects.get_step!(id)

    case Projects.update_step(step, step_params) do
      {:ok, step} ->
        conn
        |> put_flash(:info, "Step updated successfully.")
        |> redirect(to: project_step_path(conn, :show, conn.assigns.project.id, step))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", step: step, changeset: changeset)
    end
  end

  def delete(conn, %{"step_id" => id}) do
    step = Projects.get_step!(id)
    {:ok, _step} = Projects.delete_step(step)

    conn
    |> put_flash(:info, "Step deleted successfully.")
    |> redirect(to: project_step_path(conn, :index, conn.assigns.project.id))
  end
end