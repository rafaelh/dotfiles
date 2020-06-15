// Writing a setup script in Go is a terrible idea, but practice is practice.

package main

import (
	"fmt"
	"os/exec"
)

func main() {
	var cmdstring string = "pwd"
	printMessage("INFO", "Running a command")
	printMessage("WARN", "Running a command")
	printMessage("ERR", "Running a command")

	execute(cmdstring)
}

func execute(cmdstring string) {
	// Execute command and store output
	out, err := exec.Command(cmdstring).Output()
	if err != nil {
		fmt.Printf("%s", err)
	}
	fmt.Println("Command successfully executed!")

	// Convert output from []byte to string so we can output it
	output := string(out[:])
	fmt.Println(output)
}

func printMessage(level string, message string) {
	// Prints a message to the console with a coloured status (Info, Warn, Err)
	if level == "INFO" {
		fmt.Println("[\033[1;32mInfo\033[0;37m] " + message + "\033[0;37;0m")
	} else if level == "WARN" {
		fmt.Println("[\033[1;33mWarn\033[0;37m] " + message + "\033[0;37;0m")
	} else {
		fmt.Println("[\033[1;31mERR!\033[0;37m] " + message + "\033[0;37;0m")
	}

}

/*
def print_yellow(message):
    """ Prints a message to the console prefixed with a yellow '>>>' """
    print("\033[1;33;40m>>> \033[0;37;40m" + message + "\033[0;37;0m")

def print_red(message):
    """ Prints a message to the console prefixed with a red '>>>' """
    print("\033[0;31;40m>>> \033[1;37;40m" + message + "\033[0;37;0m")
*/
