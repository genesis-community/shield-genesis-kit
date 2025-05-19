package spec_test

import (
	"path/filepath"
	"runtime"

	. "github.com/genesis-community/testkit/v2/testing"
	. "github.com/onsi/ginkgo/v2"
)

var _ = BeforeSuite(func() {
	_, filename, _, _ := runtime.Caller(0)
	KitDir, _ = filepath.Abs(filepath.Join(filepath.Dir(filename), "../"))
})

var _ = Describe("Shield Kit", func() {

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
		Test(Environment{
			Name:        "stackit-base",
			CloudConfig: "stackit",
			CPI:         "stackit",
		})
		Test(Environment{
			Name:        "stackit-secure",
			CloudConfig: "stackit",
			CPI:         "stackit",
		})
		Test(Environment{
			Name:        "stackit-oauth",
			CloudConfig: "stackit",
			CPI:         "stackit",
		})
		Test(Environment{
			Name:        "stackit-postgres",
			CloudConfig: "stackit",
			CPI:         "stackit",
		})
	})
})