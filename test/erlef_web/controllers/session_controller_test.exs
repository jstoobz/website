defmodule ErlefWeb.SessionControllerTest do
  use ErlefWeb.ConnCase

  test "GET /login/init", %{conn: conn} do
    conn = get(conn, Routes.session_path(conn, :show))
    assert redirected_to(conn, 302)
  end

  describe "GET /login" do
    test "as a member", %{conn: conn} do
      params = %{
        "code" => "basic_member",
        "state" => 12_345
      }

      conn = get(conn, Routes.session_path(conn, :create), params)
      assert "/" = redir_path = redirected_to(conn, 302)
      conn = get(conn, redir_path)
      refute html_response(conn, 200) =~ "Log in"
      assert html_response(conn, 200) =~ "Log out"
    end

    test "redirects when return_to is set", %{conn: conn} do
      params = %{
        "code" => "basic_member",
        "state" => 12_345
      }

      conn =
        conn
        |> init_test_session(%{return_to: "/members/profile"})
        |> get(Routes.session_path(conn, :create), params)

      assert "/members/profile" == redirected_to(conn, 302)
    end

    @tag :only
    test "as an admin", %{conn: conn} do
      params = %{
        "code" => "admin",
        "state" => 12_345
      }

      conn = get(conn, Routes.session_path(conn, :create), params)
      assert "/" = redir_path = redirected_to(conn, 302)
      conn = get(conn, redir_path)
      refute html_response(conn, 200) =~ "Log in"
      assert html_response(conn, 200) =~ "Admin"
      assert html_response(conn, 200) =~ "Log out"
    end

    test "with no params", %{conn: conn} do
      params = %{}
      conn = get(conn, Routes.session_path(conn, :create), params)
      assert "/" = redir_path = redirected_to(conn, 302)
      conn = get(conn, redir_path)
      assert html_response(conn, 200) =~ "Invalid Login"
    end
  end

  describe "POST /logout" do
    test "as a member", %{conn: conn} do
      params = %{
        "code" => "basic_member",
        "state" => "1234567"
      }

      conn = get(conn, Routes.session_path(conn, :create), params)
      assert "/" = redir_path = redirected_to(conn, 302)
      conn = get(conn, redir_path)
      refute html_response(conn, 200) =~ "Log in"
      assert html_response(conn, 200) =~ "Log out"
      conn = post(conn, Routes.session_path(conn, :delete))
      assert "/" = redir_path = redirected_to(conn, 302)
      conn = get(conn, redir_path)
      assert html_response(conn, 200) =~ "Log in"
      refute html_response(conn, 200) =~ "Log out"
    end

    test "as an admin", %{conn: conn} do
      params = %{
        "code" => "admin",
        "state" => 12_345
      }

      conn = get(conn, Routes.session_path(conn, :create), params)
      assert "/" = redir_path = redirected_to(conn, 302)
      conn = get(conn, redir_path)
      refute html_response(conn, 200) =~ "Log in"
      assert html_response(conn, 200) =~ "Log out"
      conn = post(conn, Routes.session_path(conn, :delete))
      assert "/" = redir_path = redirected_to(conn, 302)
      conn = get(conn, redir_path)
      assert html_response(conn, 200) =~ "Log in"
      refute html_response(conn, 200) =~ "Log out"
      refute html_response(conn, 200) =~ "Admin"
    end
  end
end
