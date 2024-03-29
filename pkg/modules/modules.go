/*
Package modules implements the API defined in `api` folder
*/
package modules

import (
	"encoding/json"
	"net/http"
	"os"

	"github.com/sirupsen/logrus"
	"gitlab.magicleap.io/sre/tfregistry/pkg/backends"
)

// ModuleServer implements the interface generated by openAPI
type ModuleServer struct {
	Backend backends.BackendInterface
}

// Discovery simply returns a valid json struct
func (m *ModuleServer) Discovery(w http.ResponseWriter, r *http.Request) {

	message := map[string]string{"modules.v1": os.Getenv("MODULE_PATH")}
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)

	if err := json.NewEncoder(w).Encode(message); err != nil {
		logrus.WithError(err).Error("failed to encode JSON")
	}
}
