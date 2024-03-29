package spec_test

import (
	"path/filepath"
	"runtime"

	. "github.com/genesis-community/testkit/testing"
	. "github.com/onsi/ginkgo"
)

var _ = Describe("Shield Kit", func() {
	BeforeSuite(func() {
		_, filename, _, _ := runtime.Caller(0)
		KitDir, _ = filepath.Abs(filepath.Join(filepath.Dir(filename), "../"))
	})

	Describe("shield", func() {
		Test(Environment{
			Name:        "base",
			CloudConfig: "aws",
			CPI:         "aws",
		})
		Test(Environment{
			Name:        "oauth",
			CloudConfig: "aws",
			CPI:         "aws",
		})
		Test(Environment{
			Name:        "postgres",
			CloudConfig: "aws",
			CPI:         "aws",
		})
		Test(Environment{
			Name:        "secure",
			CloudConfig: "aws",
			CPI:         "aws",
		})
	})
})
