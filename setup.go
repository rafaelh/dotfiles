// Writing a setup script in Go is a terrible idea, but practice is practice.

package main

import (
	"fmt"
	"log"
	"os"
	"os/exec"
	"strings"
)

func main() {

	var homedir string = os.Getenv("HOME") + "/"
	fmt.Println(homedir)

	printMessage("INFO", "Running a command")
	printMessage("WARN", "Running a command")
	printMessage("ERR", "Running a command")

	cmd := exec.Command("ls", "-alh", "/etc/skel")
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	err := cmd.Run()
	if err != nil {
		log.Fatalf("cmd.Run() failed with %s\n", err)
	}
}

// Execute command and store output
func execute(cmdstring string) {
	out, err := exec.Command(cmdstring).Output()
	if err != nil {
		fmt.Printf("%s", err)
	}
	output := string(out[:]) // Convert from []byte -> string so we can display output
	fmt.Println(output)
}

// Prints a message to the console with a coloured status (Info, Warn, Err)
func printMessage(messageLevel string, message string) {
	var level = strings.ToLower(messageLevel)
	if level == "info" {
		fmt.Println("[\033[1;32mInfo\033[0;37m] " + message + "\033[0;37m")
	} else if level == "warn" {
		fmt.Println("[\033[1;33mWarn\033[0;37m] " + message + "\033[0;37m")
	} else {
		fmt.Println("[\033[1;31mERR!\033[0;37m] " + message + "\033[0;37m")
	}

}

/* TO DO:

* https://blog.kowalczyk.info/article/wOYk/advanced-command-execution-in-go-with-osexec.html
* https://golang.org/pkg/os/
* Remove the default files in /etc/skel and replace with ones from dotfiles/config
* Sync the vim plugins directory
* Create symlinks for useful directories if they exist - gdrive, documents, etc
* Sync git repositories
* Define and build go modules (then create a separate go module to rebuild them)

 */
