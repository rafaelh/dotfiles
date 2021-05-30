// Writing a setup script in Go is a terrible idea, but practice is practice.
package main

import (
	"fmt"
	"io/ioutil"
	"log"
	"os"
	"os/exec"
	"strings"
)

func main() {

	var homedir string = os.Getenv("HOME") + "/"
	fmt.Println(homedir) // /home/rafael
	var repodir string = homedir + "x/"
	fmt.Println(repodir) //  /home/rafael/x/

	files, err := ioutil.ReadDir("/home/rafael/x")
	if err != nil {
		log.Fatal(err)
	}
	fmt.Println(files)

	printMessage("INFO", "Running a command")
	printMessage("ADD", "Running a command")
	printMessage("WARN", "Running a command")
	printMessage("ERR", "Running a command")

	cmd := exec.Command("ls", "-alh", "/etc/skel")
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	err := cmd.Run()
	if err != nil {
		fmt.Println("cmd.Run() failed: ", err)
	}

}

// Check if a given file or directory exists
func exists(path string) (bool, error) {
	_, err := os.Stat(path)
	if err == nil {
		return true, nil
	}
	if os.IsNotExist(err) {
		return false, nil
	}
	return false, err
}

// Prints a message to the console with a coloured status (Info, Warn, Err)
func printMessage(messageLevel string, message string) {
	var level = strings.ToLower(messageLevel)
	if level == "info" {
		fmt.Println("\033[1;34m[i]\033[0;37m " + message)
	} else if level == "add" {
		fmt.Println("\033[1;32m[+]\033[0;37m " + message)
	} else if level == "warn" {
		fmt.Println("\033[1;33m[*]\033[0;37m " + message)
	} else {
		fmt.Println("\033[1;31m[!]\033[0;37m " + message)
	}

}

/* TO DO:

* https://gobyexample.com/directories
* https://blog.kowalczyk.info/article/wOYk/advanced-command-execution-in-go-with-osexec.html
* https://golang.org/pkg/os/
* Remove the default files in /etc/skel and replace with ones from dotfiles/config
* Sync the vim plugins directory
* Create symlinks for useful directories if they exist - gdrive, documents, etc
* Sync git repositories
* Define and build go modules (then create a separate go module to rebuild them)

 */
