// Main App Component
const { useState, useEffect } = React;

const App = () => {
  const [jobs, setJobs] = useState([
    {
      id: 1,
      fileName: 'document.pdf',
      status: 'running',
      startTime: new Date(Date.now() - 300000), // 5 minutes ago
      progress: 45,
      estimatedTimeLeft: '10m 30s'
    },
    {
      id: 2,
      fileName: 'archive.zip',
      status: 'completed',
      startTime: new Date(Date.now() - 1200000), // 20 minutes ago
      endTime: new Date(Date.now() - 600000), // 10 minutes ago
      password: 'secret123'
    },
    {
      id: 3,
      fileName: 'presentation.pptx',
      status: 'failed',
      startTime: new Date(Date.now() - 60000), // 1 minute ago
      endTime: new Date(Date.now() - 30000), // 30 seconds ago
      error: 'Wordlist exhausted'
    }
  ]);
  
  const [stats, setStats] = useState({
    totalJobs: 12,
    runningJobs: 1,
    completedJobs: 8,
    failedJobs: 3
  });
  
  const [newJob, setNewJob] = useState({
    fileName: '',
    wordlistUrl: '',
    timeout: 3600
  });

  const getStatusColor = (status) => {
    switch(status) {
      case 'running': return '#f39c12';
      case 'completed': return '#2ecc71';
      case 'failed': return '#e74c3c';
      default: return '#95a5a6';
    }
  };

  const getStatusText = (status) => {
    switch(status) {
      case 'running': return 'Running';
      case 'completed': return 'Completed';
      case 'failed': return 'Failed';
      default: return 'Pending';
    }
  };

  const handleSubmitJob = (e) => {
    e.preventDefault();
    if (!newJob.fileName) return;
    
    const job = {
      id: jobs.length + 1,
      fileName: newJob.fileName,
      status: 'running',
      startTime: new Date(),
      progress: 0
    };
    
    setJobs([job, ...jobs]);
    setStats(prev => ({
      ...prev,
      totalJobs: prev.totalJobs + 1,
      runningJobs: prev.runningJobs + 1
    }));
    
    // Reset form
    setNewJob({ fileName: '', wordlistUrl: '', timeout: 3600 });
  };

  const handleInputChange = (e) => {
    const { name, value } = e.target;
    setNewJob(prev => ({ ...prev, [name]: value }));
  };

  // Simulate job progress
  useEffect(() => {
    const interval = setInterval(() => {
      setJobs(prevJobs => 
        prevJobs.map(job => {
          if (job.status === 'running' && job.progress < 100) {
            const increment = Math.random() * 5;
            const newProgress = Math.min(job.progress + increment, 100);
            
            if (newProgress === 100) {
              // Randomly determine if job completes or fails
              const isSuccess = Math.random() > 0.3; // 70% success rate
              
              setStats(prev => ({
                ...prev,
                runningJobs: prev.runningJobs - 1,
                [isSuccess ? 'completedJobs' : 'failedJobs']: 
                  prev[isSuccess ? 'completedJobs' : 'failedJobs'] + 1
              }));
              
              return {
                ...job,
                status: isSuccess ? 'completed' : 'failed',
                progress: 100,
                endTime: new Date(),
                ...(isSuccess ? { password: 'found_password' } : { error: 'Cracking failed' })
              };
            }
            
            return { ...job, progress: newProgress };
          }
          return job;
        })
      );
    }, 2000); // Update every 2 seconds

    return () => clearInterval(interval);
  }, []);

  return (
    <div className="container">
      <div className="header">
        <h1>John the Ripper Dashboard</h1>
        <p>Monitor and manage password cracking jobs</p>
      </div>

      {/* Stats Cards */}
      <div className="stats-container">
        <div className="stat-card">
          <div className="stat-number">{stats.totalJobs}</div>
          <div className="stat-label">Total Jobs</div>
        </div>
        <div className="stat-card">
          <div className="stat-number">{stats.runningJobs}</div>
          <div className="stat-label">Running</div>
        </div>
        <div className="stat-card">
          <div className="stat-number">{stats.completedJobs}</div>
          <div className="stat-label">Completed</div>
        </div>
        <div className="stat-card">
          <div className="stat-number">{stats.failedJobs}</div>
          <div className="stat-label">Failed</div>
        </div>
      </div>

      {/* Job Submission Form */}
      <div className="card">
        <h2 className="card-title">Submit New Job</h2>
        <form onSubmit={handleSubmitJob}>
          <div className="form-group">
            <label htmlFor="fileName">File Name</label>
            <input
              type="text"
              id="fileName"
              name="fileName"
              value={newJob.fileName}
              onChange={handleInputChange}
              placeholder="Enter file name or path"
              required
            />
          </div>
          <div className="form-group">
            <label htmlFor="wordlistUrl">Wordlist URL (optional)</label>
            <input
              type="text"
              id="wordlistUrl"
              name="wordlistUrl"
              value={newJob.wordlistUrl}
              onChange={handleInputChange}
              placeholder="URL to download wordlist from"
            />
          </div>
          <div className="form-group">
            <label htmlFor="timeout">Timeout (seconds)</label>
            <input
              type="number"
              id="timeout"
              name="timeout"
              value={newJob.timeout}
              onChange={handleInputChange}
              min="1"
              max="86400" // 24 hours
            />
          </div>
          <button type="submit" className="btn">Submit Job</button>
        </form>
      </div>

      {/* Active Jobs */}
      <div className="card">
        <h2 className="card-title">Active Jobs</h2>
        <div className="status-grid">
          {jobs
            .filter(job => job.status !== 'completed' && job.status !== 'failed')
            .map(job => (
              <div 
                key={job.id} 
                className={`job-card ${job.status}`}
                style={{borderLeftColor: getStatusColor(job.status)}}
              >
                <div className="job-header">
                  <div className="job-title">{job.fileName}</div>
                  <div className={`job-status status-${job.status}`}>
                    {getStatusText(job.status)}
                  </div>
                </div>
                <div className="job-details">
                  <div>Started: {job.startTime.toLocaleTimeString()}</div>
                  {job.status === 'running' && (
                    <>
                      <div>Progress: {Math.round(job.progress)}%</div>
                      <div>Est. time left: {job.estimatedTimeLeft || 'Calculating...'}</div>
                    </>
                  )}
                </div>
                {job.status === 'running' && (
                  <div style={{marginTop: '10px'}}>
                    <div style={{display: 'flex', alignItems: 'center'}}>
                      <div 
                        style={{
                          height: '10px',
                          backgroundColor: '#3498db',
                          width: `${job.progress}%`,
                          borderRadius: '5px',
                          transition: 'width 0.3s'
                        }}
                      ></div>
                    </div>
                  </div>
                )}
              </div>
            ))}
        </div>
      </div>

      {/* Completed/Failed Jobs */}
      <div className="card">
        <h2 className="card-title">Recent Jobs</h2>
        <div className="status-grid">
          {jobs
            .filter(job => job.status === 'completed' || job.status === 'failed')
            .map(job => (
              <div 
                key={job.id} 
                className={`job-card ${job.status}`}
                style={{borderLeftColor: getStatusColor(job.status)}}
              >
                <div className="job-header">
                  <div className="job-title">{job.fileName}</div>
                  <div className={`job-status status-${job.status}`}>
                    {getStatusText(job.status)}
                  </div>
                </div>
                <div className="job-details">
                  <div>Started: {job.startTime.toLocaleTimeString()}</div>
                  <div>Ended: {job.endTime?.toLocaleTimeString() || 'N/A'}</div>
                  {job.password && (
                    <div><strong>Password:</strong> {job.password}</div>
                  )}
                  {job.error && (
                    <div><strong>Error:</strong> {job.error}</div>
                  )}
                </div>
              </div>
            ))}
        </div>
      </div>

      <div className="footer">
        <p>John the Ripper Dashboard v1.0 • For authorized use only</p>
      </div>
    </div>
  );
};

// Render the app
const root = ReactDOM.createRoot(document.getElementById('root'));
root.render(<App />);