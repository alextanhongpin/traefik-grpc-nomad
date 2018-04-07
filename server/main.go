package main

import (
	"context"
	"crypto/tls"
	"io/ioutil"
	"log"
	"net"
	"os"

	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials"
	"google.golang.org/grpc/reflection"

	pb "github.com/alextanhongpin/traefik-grpc/proto"
)

type echoServer struct{}

func (s *echoServer) Echo(ctx context.Context, msg *pb.EchoRequest) (*pb.EchoResponse, error) {
	name, _ := os.Hostname()
	port := os.Getenv("PORT")
	return &pb.EchoResponse{
		Text: msg.Text + " hostname: " + name + " port: " + port,
	}, nil
}

func main() {
	port := os.Getenv("PORT")
	//
	// CRED
	//
	BackendCert, _ := ioutil.ReadFile("/Users/alextanhongpin/Documents/architecture/traefik-grpc/backend.cert")
	BackendKey, _ := ioutil.ReadFile("/Users/alextanhongpin/Documents/architecture/traefik-grpc/backend.key")

	// Generate Certificate struct
	cert, err := tls.X509KeyPair(BackendCert, BackendKey)
	if err != nil {
		log.Fatalf("failed to parse certificate: %v", err)
	}

	// Create credentials
	creds := credentials.NewServerTLSFromCert(&cert)

	// Use Credentials in gRPC server options
	serverOption := grpc.Creds(creds)

	//
	// SERVER
	//
	lis, err := net.Listen("tcp", ":"+port)
	if err != nil {
		log.Fatalf("failed to listen: %s", err.Error())
	}

	grpcServer := grpc.NewServer(serverOption)
	defer grpcServer.Stop()

	pb.RegisterEchoServiceServer(grpcServer, &echoServer{})
	reflection.Register(grpcServer)
	log.Println("listening to server at port *:" + port + ". press ctrl + c to cancel.")
	log.Fatal(grpcServer.Serve(lis))
}
