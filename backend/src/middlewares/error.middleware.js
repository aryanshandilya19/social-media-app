const errorHandler = (err, req, res, next) => {
  console.error("ERROR 💥", {
    message: err.message,
    path: req.originalUrl,
    method: req.method,
    stack: err.stack,
  });

  res.status(err.statusCode || 500).json({
    success: false,
    message: err.message || "Internal Server Error",
  });
};

export default errorHandler;
