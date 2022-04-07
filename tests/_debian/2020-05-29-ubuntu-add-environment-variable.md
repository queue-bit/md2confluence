---

title:  "Ubuntu - Add System-Wide Environment Variables"
excerpt: "Using profile.d for loading environment variables"
tags: "ubuntu environment variables profile.d"
---

I typically use profile.d for loading Environment Variables. There are other methods but I find this easier to maintain.

## Steps

1. Use `echo` to output the `export` command, then redirect (`>>`) the output to a file in the `profile.d` directory:

    ```zsh
    sudo sh -c 'echo "export {YOUR_VARIABLE_NAME}={your-variable-value}" >>  /etc/profile.d/{your-variable-name}.sh'
    ```   

    - For the curious, here's how that breaks down:

        | Command | Explanation |
        | -| - | 
        | `sudo` | Substitute User Do (previously "Superuser Do") - run command as a user with privileges, defaults to 'super user' |
        | `sh` | In a shell (command interpreter) |
        | `-c` | Use commands from the command_string (the next part, between `'` and `'`) |
        | `echo` | Output a line of text (the part between `"` and `"`) |
        | `export` | Set the export attribute for variables | 
        | `>> /etc/profile.d/{your-variable-name}.sh` | Append Redirected Output (`>>`) to the specified file (`/etc/profile.d/{your-variable-name}.sh`) |

1. Use `chmod +x` to mark the new file as executable:

    ```zsh
    ~ chmod +x /etc/profile.d/{your-variable-name}.sh
    ```

1. Use `source` to load the `/etc/profile.d/{your-variable-name}.sh` file into the current shell (this saves us from having to logout and back in):

    ```zsh
    ~ source /etc/profile.d/{your-variable-name}.sh 
    ```

1. Test that the variable is loaded by echoing it:

    ```zsh
    ~ echo ${YOUR_VARIABLE_NAME}
    ```
    - You'll get a reply of {your-variable-value}

## Example

In this example I create a new shell file in profile.d that exports an Environment Variable with the name `TEST_API_KEY` and value `mykeyishere`. I then make it executable, use `source` to load it, then `echo` it to make sure it's properly set.

```zsh
~ sudo sh -c 'echo "export TEST_API_KEY=mykeyishere" >>  /etc/profile.d/test-key.sh' 
[sudo] password for user: _
~ sudo chmod +x /etc/profile.d/test-key.sh 
~ source /etc/profile.d/test-key.sh 
~ echo $TEST_API_KEY
mykeyishere
~_
```