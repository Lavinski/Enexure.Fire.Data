using System;
using System.Collections.Generic;
using System.Data.Common;
using System.Linq;
using System.Threading.Tasks;

namespace Enexure.Fire.Data
{
	public class DataResultAsync : DataResultBase, IDataResultAsync
	{
		private readonly DbDataReader dataReader;

		public DataResultAsync(DbDataReader dataReader)
		{
			this.dataReader = dataReader;
		}

		public async Task<IList<T>> ToListAsync<T>()
		{
			var list = new List<T>();
			var mapper = new Mapper(typeof(T));

			while (await dataReader.ReadAsync()) {
				list.Add(mapper.GetRow<T>(dataReader));
			}
			return list;
		}

		public async Task ToCallbacks<T>(Action<T> callback)
		{
			var mapper = new Mapper(typeof(T));

			while (await dataReader.ReadAsync())
			{
				callback(mapper.GetRow<T>(dataReader));
			}
		}

		public async Task<T> SingleAsync<T>()
		{
			return (await ToListAsync<T>()).Single();
		}

		public async Task<T> SingleOrDefaultAsync<T>()
			where T : class 
		{
			return (await ToListAsync<T>()).SingleOrDefault();
		}

		public void Dispose()
		{
			dataReader.Dispose();
		}
	}
}