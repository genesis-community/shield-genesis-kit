package spec_test

import (
	"os"
	"os/exec"
	"path/filepath"

	. "github.com/genesis-community/testkit/v2/testing"
	. "github.com/onsi/ginkgo/v2"
	. "github.com/onsi/gomega"
)

// The addon hooks are Perl, so their cases live in a Perl test file that this
// spec runs. That keeps them in the same `go test ./...` run as everything
// else, rather than in a command someone has to remember.
var _ = Describe("Shield Kit Addons", func() {
	Describe("runtime-config", func() {
		It("renders the agent runtime-config and honours its options", func() {
			test := filepath.Join(KitDir, "spec", "addon", "runtime-config.t")
			Expect(test).To(BeAnExistingFile())

			cmd := exec.Command("perl", test)
			cmd.Stdin = nil
			cmd.Stdout = GinkgoWriter
			cmd.Stderr = GinkgoWriter
			cmd.Env = append(os.Environ(), "GENESIS_TESTING=1")

			Expect(cmd.Run()).To(Succeed(), "see the TAP output above for the failing case")
		})
	})
})
