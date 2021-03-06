defmodule Integration.SlackTest do
  use Cog.AdapterCase, adapter: "slack"

  @moduletag :slack

  # Name of the Slack user we'll be interacting with the bot as
  @user "botci"

  # Name of the bot we'll be operating as
  @bot "deckard"

  setup do
    # The user always interacts with the bot via the `@user` account
    # (see above). Our helper functions set up a user with the same
    # Cog username and Slack handle
    user = user(@user)
    |> with_chat_handle_for("slack")

    {:ok, %{user: user}}
  end

  test "editing a command", %{user: user} do
    user |> with_permission("operable:st-echo")

    message = send_edited_message("@#{@bot}: operable:st-echo test")
    assert_edited_response "@#{@user} Executing edited command 'operable:st-echo test'\ntest", after: message
  end

  test "running the st-echo command", %{user: user} do
    user |> with_permission("operable:st-echo")

    message = send_message("@#{@bot}: operable:st-echo test")
    assert_response "test", after: message
  end

  test "running the st-echo command without permission" do
    message = send_message("@#{@bot}: operable:st-echo test")
    assert_response_contains "Sorry, you aren't allowed to execute 'operable:st-echo test' :(\n You will need at least one of the following permissions to run this command: 'operable:st-echo'", after: message
  end

  test "running commands in a pipeline", %{user: user} do
    user
    |> with_permission("operable:echo")
    |> with_permission("operable:thorn")

    message = send_message(~s(@#{@bot}: seed '[{"test": "blah"}]' | echo $test))
    assert_response "blah", after: message
  end

  test "running commands in a pipeline without permission", %{user: user} do
    user |> with_permission("operable:st-echo")

    message = send_message(~s(@#{@bot}: operable:st-echo "this is a test" | operable:st-thorn $body))
    assert_response_contains "Sorry, you aren't allowed to execute 'operable:st-thorn $body' :(\n You will need at least one of the following permissions to run this command: 'operable:st-thorn'", after: message
  end

  test "sending a message to a group", %{user: user} do
    user |> with_permission("operable:echo")
    private_channel = "#group_ci_bot_testing"

    message = send_message("@#{@bot}: operable:echo blah", private_channel)
    assert_response "blah", [after: message], private_channel
  end

  test "redirecting from a private channel", %{user: user} do
    user |> with_permission("operable:echo")
    private_channel = "#group_ci_bot_testing"
    marker = send_message("Redirect test starts here")

    send_message("@#{@bot}: operable:echo blah > #ci_bot_testing", private_channel)
    assert_response "blah", [after: marker]
  end

  test "redirecting to a private channel", %{user: user} do
    user |> with_permission("operable:echo")
    private_channel = "#group_ci_bot_testing"
    marker = send_message("Redirect test starts here", private_channel)

    send_message("@#{@bot}: operable:echo blah > #{private_channel}")
    assert_response "blah", [after: marker], private_channel
  end

  test "redirecting to 'here'", %{user: user} do
    user |> with_permission("operable:echo")

    message = send_message("@#{@bot}: operable:echo blah > here")
    assert_response "blah", [after: message]
  end

  test "redirecting to 'me'", %{user: user} do
    user |> with_permission("operable:echo")
    marker = send_message("echo here", "@#{@user}")

    send_message("@#{@bot}: operable:echo blah > me")
    # Since Cog responds when direct messaging it we have to assert
    # that both our marker text and message test exist.
    assert_response "here\nblah", [after: marker, count: 2], "@#{@user}"
  end

  test "redirecting to a specific user", %{user: user} do
    user |> with_permission("operable:echo")
    marker = send_message("echo here", "@#{@user}")

    send_message("@#{@bot}: operable:echo blah > @#{@user}")
    # Since Cog responds when direct messaging it we have to assert
    # that both our marker text and message test exist.
    assert_response "here\nblah", [after: marker, count: 2], "@#{@user}"
  end

  test "redirecting to another channel", %{user: user} do
    user |> with_permission("operable:echo")
    redirect_channel = "#ci_bot_redirect_tests"
    marker = send_message("echo here", redirect_channel)

    send_message("@#{@bot}: operable:echo blah > #{redirect_channel}")
    assert_response "blah", [after: marker], redirect_channel
  end
end
